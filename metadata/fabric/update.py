#!/usr/bin/env python
import requests
import json
from requests.exceptions import RequestException
from sys import stderr

HASH_TYPES = [ "sha512", "sha256", "sha1" ]
META_SERVER = "https://meta.fabricmc.net"

# attributes
JVM = "jvm"
URL = "url"
GAME = "game"
HASH = "hash"
NAME = "name"
PATH = "path"
REPO = "repo"
TYPE = "type"
VALUE = "value"
CLIENT = "client"
LOADER = 'loader'
STABLE = "stable"
VERSION = 'version'
ARGUMENTS = "arguments"
LIBRARIES = "libraries"
MAIN_CLASS = "mainClass"

with open('./libraries.json') as f:
    previous_libraries = json.load(f)

libraries = {}
profiles = {}
loaders = {}

def fetch(url):
    response = requests.get(url)
    if response.status_code == 200:
        return response
    else:
        raise RequestException(f"{response.status_code} returned from {url}.")

def fetch_and_update(game_version, loader_info):
    loader_version = loader_info[LOADER][VERSION]
    print(f"Fetch and update for game {game_version} and loader {loader_version}")
    
    url_client = f"{META_SERVER}/v2/versions/loader/{game_version}/{loader_version}/profile/json"
    
    client_response = fetch(url_client).json()
    client_libraries = client_response[LIBRARIES]
    client_main_class = client_response[MAIN_CLASS]

    for library in client_libraries:
        if URL in library:
            update_library(library[NAME], library[URL])
        # Otherwise the library should already present in vanilla version

    client_library_names = set(map(lambda l: l[NAME], client_libraries))

    # Calculate minimum set of required library for each loader
    common_names = client_library_names.intersection()
    if loader_version in loaders:
        loaders[loader_version][LIBRARIES] = loaders[loader_version][LIBRARIES].intersection(common_names)
    else:
        loaders[loader_version] = { LIBRARIES: common_names, MAIN_CLASS: { CLIENT: client_main_class } }
    
    profiles[game_version] = {
        LOADER: loader_version,
        LIBRARIES: {
            CLIENT: client_library_names
        }
    }
    
def update_library(name, url):
    if name in libraries:
        return

    if name in previous_libraries:
        libraries[name] = previous_libraries[name]
        return

    print(f"Update hash for {name}.")
    [org,art,ver] = name.split(':')
    path = f"{org.replace('.','/')}/{art}/{ver}/{art}-{ver}.jar"
    base_url = f"{url}/{path}"
    for hash_type in HASH_TYPES:
        try:
            response = fetch(f"{base_url}.{hash_type}")
            libraries[name] = { REPO: url, HASH: { TYPE: hash_type, VALUE: response.text } }
            return
        except RequestException as e:
            print(f"Error when fetch {hash_type} for {name}: {str(e)}", file=stderr)
    
    raise RequestException(f"Failed to fetch hash value for {name}.")

def get_game_versions():
    return map(lambda v: v["version"], fetch(f"{META_SERVER}/v2/versions/game").json())

def get_loader_infos(game_version):
    return fetch(f"{META_SERVER}/v2/versions/loader/{game_version}").json()

def update_profiles():
    for version in profiles:
        profile = profiles[version]
        profile[LIBRARIES][CLIENT] = sorted(list(profile[LIBRARIES][CLIENT].difference(loaders[profile[LOADER]][LIBRARIES])))
    
    for loader in loaders:
        loaders[loader][LIBRARIES] = sorted(list(loaders[loader][LIBRARIES]))

for game_version in get_game_versions():
    # Only fetch latest stable loader now
    for loader_info in get_loader_infos(game_version):
        if loader_info[LOADER][STABLE]:
            fetch_and_update(game_version, loader_info)
            break

update_profiles()

with open("libraries.json", 'w+') as f:
    json.dump(libraries, f, indent=2, sort_keys=True)

with open("profiles.json", 'w+') as f:
    json.dump(profiles, f, indent=2, sort_keys=True)

with open('loaders.json', 'w+') as f:
    json.dump(loaders, f, indent=2, sort_keys=True)
