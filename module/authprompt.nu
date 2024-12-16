#!/usr/bin/env nu

def main [code] {
#   if $env.XDG_SESSION_TYPE == "wayland" {
#     print "Session is wayland, using wl-copy"
#     nu -c $"wl-copy ($code)"
#   } else if $env.XDG_SESSION_TYPE == "x11" {
#     print "Session is x11, using xclip"
#     nu -c $"echo $"($code)" | xclip -selection clipboard"
#   }
  nu -c $"zenity --info --no-wrap --title='MC Auth Code: ($code)' --text='
  <span size="12000" weight="bold">Go to <a href="https://microsoft.com/link">https://microsoft.com/link</a> and enter the code</span>
  The script has attempted to copy the code to your clipboard
  '"
}
