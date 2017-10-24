#!/usr/bin/env bash

echo "✨ Starting JS build"
cd "$(dirname $0)/www"

if hash yarn 2>/dev/null; then
    yarn
else
    npm install
fi

npm run build