#!/usr/bin/env bash

# this script opens 1000 tabs (50 tabs per window)
# runs with Chrome on macOS or NixOS (Linux)

function open_url {
  case "$OSTYPE" in
    darwin*)  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome http://$1 ;;
    linux*)   google-chrome-beta http://$1 ;;
    msys*)    "WINDOWS not supported" exit ;;
    *)        exit 1;;
  esac
}

function open_url_in_new_window {
  case "$OSTYPE" in
    darwin*)  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --new-window http://$1 ;;
    linux*)   google-chrome-beta --new-window http://$1 ;;
    msys*)    "WINDOWS not supported" exit ;;
    *)        exit 1;;
  esac
}

# download list of the top 1 million domains from Alexa
if [ ! -f domains.txt ]; then
  if [ ! -f top-1m.csv.zip ]; then
    echo "download domain list..."
    curl -O http://s3.amazonaws.com/alexa-static/top-1m.csv.zip
  fi
  echo "extract domain list..."
  unzip -p top-1m.csv.zip | cut -d, -f2 > domains.txt
fi

# create array from file
IFS=$'\n' read -d '' -r -a domains < domains.txt

# open chrome
case "$OSTYPE" in
  darwin*)  open -a /Applications/Google\ Chrome.app ;;
  linux*)   google-chrome-beta & ;;
  msys*)    echo "WINDOWS not supported" exit ;;
  *)        exit 1;;
esac

for i in $(seq 0 999); do
  # sleep after opening 100 tabs to suspend them
  if (( $i % 100 == 0 )); then
    echo "sleep 60 seconds..."
    sleep 60
  fi

  echo -e "\n# open URL Nr. $i (${domains[i]})"
  if (( $i % 50 == 0 )); then # every 50th
    open_url_in_new_window "${domains[i]}"
  else
    open_url "${domains[i]}"
  fi
done

