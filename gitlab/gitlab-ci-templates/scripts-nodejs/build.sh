#!/bin/bash

set -e

echo "--------- npm install"
npm install

echo "--------- npm run build"
npm run build

exit 0
