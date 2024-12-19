import json, pathlib, requests, sys, time, os, subprocess

def saveTokens(tokens):
    cachePath = pathlib.Path.home() / ".local/share" / "mc-nix-creds.json"
    with open(cachePath, 'w') as f:
        json.dump(tokens, f)

def loadTokens():
    cachePath = pathlib.Path.home() / ".local/share" / "mc-nix-creds.json"
    if not cachePath.exists():
        return None
    
    try:
        with open(cachePath, 'r') as f:
            tokens = json.load(f)

        profileResponse = requests.get("https://api.minecraftservices.com/minecraft/profile",
            headers={"Authorization": f"Bearer {tokens['accessToken']}"}
        )
        
        if profileResponse.status_code == 200:
            return tokens
        return None
    
    except Exception:
        return None

def authenticate():
    cachedTokens = loadTokens()
    if cachedTokens:
        print("Authentication successful using cached credentials")
        return

    clientParams = { "client_id": "bf2147ae-08d3-40d4-8fb0-27094463f460", "scope": "offline_access XboxLive.signin" }
    
    deviceAuthUrl = "https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode"
    tokenUrl = "https://login.microsoftonline.com/consumers/oauth2/v2.0/token"
    
    try:
        # Request device authorization
        response = requests.post(deviceAuthUrl, data=clientParams)
        response.raise_for_status()
        authData = response.json()
        
        print(f"User Code: {authData['user_code']}")
        print(f"Verification URL: {authData['verification_uri']}")
        subprocess.run([f"./auth.nu {authData['user_code']}"], shell=True)
        
        tokenParams = {
            "client_id": clientParams["client_id"],
            "device_code": authData['device_code'],
            "grant_type": "urn:ietf:params:oauth:grant-type:device_code"
        }
        
        while True:
            tokenResponse = requests.post(tokenUrl, data=tokenParams)
            tokenData = tokenResponse.json()

            if 'access_token' in tokenData:
                xboxTokenResponse = requests.post("https://user.auth.xboxlive.com/user/authenticate", 
                    json={
                        "Properties": {
                            "AuthMethod": "RPS",
                            "SiteName": "user.auth.xboxlive.com",
                            "RpsTicket": f"d={tokenData['access_token']}"
                        },
                        "RelyingParty": "http://auth.xboxlive.com",
                        "TokenType": "JWT"
                    }
                )
                xboxTokenData = xboxTokenResponse.json()

                xstsTokenResponse = requests.post("https://xsts.auth.xboxlive.com/xsts/authorize",
                    json={
                        "Properties": {
                            "SandboxId": "RETAIL",
                            "UserTokens": [xboxTokenData['Token']]
                        },
                        "RelyingParty": "rp://api.minecraftservices.com/",
                        "TokenType": "JWT"
                    }
                )
                xstsTokenData = xstsTokenResponse.json()

                minecraftTokenResponse = requests.post("https://api.minecraftservices.com/authentication/login_with_xbox",
                    json={
                        "identityToken": f"XBL3.0 x={xstsTokenData['DisplayClaims']['xui'][0]['uhs']};{xstsTokenData['Token']}"
                    }
                )
                minecraftTokenData = minecraftTokenResponse.json()

                profileResponse = requests.get("https://api.minecraftservices.com/minecraft/profile",
                    headers={
                        "Authorization": f"Bearer {minecraftTokenData['access_token']}"
                    }
                )
                if profileResponse.status_code == 200:
                    profileData = profileResponse.json()
                    saveTokens({
                        "accessToken": minecraftTokenData['access_token'],
                        "uuid": profileData['id'],
                        "username": profileData['name']
                    })
                    
                    print("Authentication successful")
                else:
                    print("Error: User does not own Minecraft: Java Edition")
                    sys.exit(1)
                break
            
            elif tokenData.get('error') == 'authorization_pending':
                time.sleep(5)
            else:
                print(f"Token retrieval error: {tokenData}")
                sys.exit(1)
    
    except Exception as e:
        import traceback
        print(f"Unexpected error: {e}")
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)

authenticate()