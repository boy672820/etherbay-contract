#!/bin/sh

# Run hardhat
echo "Run hardhat node.."
npm run node && npm run deploy

# Keep node alive
set -e
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- node "$@"
fi
exec "$@"
