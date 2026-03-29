#!/usr/bin/env sh
# abort on errors
set -e
# build
export NODE_OPTIONS=--openssl-legacy-provider npm run serve
npm run build
# navigate into the build output directory
cd dist
# if you are deploying to a custom domain
# echo 'www.example.com' > CNAME
git init
git add -A
git commit -m 'deploy'
git push -f git@github.com:robhjoh/sitt.git master:gh-pages
cd -