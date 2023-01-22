#!/bin/bash

set -euo pipefail

# https://scriptingosx.com/2021/07/notarize-a-command-line-tool-with-notarytool/

#if [[ $# -ne 1 ]]; then
#  echo "$0 requires one argument - SwiftSearcher's xcarchive output directory"
#  exit 2
#fi

NAME="sws"
ROOT_DIR="/Users/danielbeard/Library/Developer/Xcode/Archives/2023-01-21/sws 1-21-23, 3.25 PM.xcarchive/Products"
VERSION="0.1"

#TODODB: Figure out how to remove this as part of regular archive
set +e
rm -r "$ROOT_DIR/usr/local/bin/Frameworks"
set -e

pkgbuild --root "$ROOT_DIR" \
           --identifier "io.danielbeard.sws" \
           --version "$VERSION" \
           --install-location "/" \
           --sign "Developer ID Installer: Daniel Beard (6T8835Q6XM)" \
           "$NAME-$VERSION.pkg"

xcrun notarytool submit "$NAME-$VERSION".pkg \
                   --keychain-profile "sws" \
                   --wait
