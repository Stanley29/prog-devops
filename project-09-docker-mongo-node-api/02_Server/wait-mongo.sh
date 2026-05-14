#!/usr/bin/env sh

echo "Waiting for MongoDB to be ready..."

until curl -s http://geography-db:27017 >/dev/null 2>&1; do
  echo "MongoDB is not ready yet..."
  sleep 2
done

echo "MongoDB is ready. Starting server..."
node server.js
