#!/bin/bash

# Simple script to create groups and users for Task 2

# Groups
DEV_GROUP="Dev2"
OPS_GROUP="Ops2"

# Users
DEV_USER="devuser2"
OPS_USER="opsuser2"
TEST_USER="testuser2"

echo "=== Creating groups ==="

# Create Dev2 group
if getent group "$DEV_GROUP" > /dev/null 2>&1; then
  echo "Group $DEV_GROUP already exists. Skipping."
else
  sudo groupadd "$DEV_GROUP"
  echo "Group $DEV_GROUP created."
fi

# Create Ops2 group
if getent group "$OPS_GROUP" > /dev/null 2>&1; then
  echo "Group $OPS_GROUP already exists. Skipping."
else
  sudo groupadd "$OPS_GROUP"
  echo "Group $OPS_GROUP created."
fi

echo "=== Creating users ==="

# Function to create user if not exists
create_user() {
  local USERNAME="$1"
  if id "$USERNAME" > /dev/null 2>&1; then
    echo "User $USERNAME already exists. Skipping."
  else
    sudo adduser --disabled-password --gecos "" "$USERNAME"
    echo "User $USERNAME created."
  fi
}

create_user "$DEV_USER"
create_user "$OPS_USER"
create_user "$TEST_USER"

echo "=== Adding users to groups ==="

# devuser2 -> Dev2
sudo usermod -aG "$DEV_GROUP" "$DEV_USER"

# opsuser2 -> Dev2 + Ops2
sudo usermod -aG "$DEV_GROUP" "$OPS_USER"
sudo usermod -aG "$OPS_GROUP" "$OPS_USER"

# testuser2 -> no groups (intentionally)

echo "=== Result ==="
echo "Groups:"
getent group "$DEV_GROUP"
getent group "$OPS_GROUP"

echo "Users:"
id "$DEV_USER"
id "$OPS_USER"
id "$TEST_USER"

echo "Done."
