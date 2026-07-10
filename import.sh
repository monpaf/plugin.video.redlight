#!/bin/bash

UPSTREAM_URL="https://github.com/The-Red-Wizard/TheRedWizard.git"
ADDON="plugin.video.redlight"
XML_FILE="$ADDON/addon.xml"

if ! git remote | grep -q "^upstream$"; then
    git remote add upstream "$UPSTREAM_URL"
fi

git fetch upstream
git checkout upstream/main -- "$ADDON"

VERSION=$(sed -n 's/.*[^0-9]\([0-9]\+\.[0-9]\+\.[0-9]\+\)">.*/\1/p' "$XML_FILE" | head -n 1)

git add "$ADDON"
git add --renormalize "$ADDON"
git commit -m "chore: import v$VERSION"
