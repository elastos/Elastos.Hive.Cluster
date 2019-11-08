#!/bin/sh

set -e
if [ -n "$DOCKER_DEBUG" ]; then
   set -x
fi
user=ipfs
export CLUSTER_SECRET="d2b0fb2c1efc772e5720c0f659bffa0fb800efcdebc8c7e9b94c183f2a285546"

if [ `id -u` -eq 0 ]; then
    echo "Changing user to $user"
    # ensure directories are writable
    su-exec "$user" test -w "${IPFS_PATH}" || chown -R -- "$user" "${IPFS_PATH}"
    su-exec "$user" test -w "${IPFS_CLUSTER_PATH}" || chown -R -- "$user" "${IPFS_CLUSTER_PATH}"
    exec su-exec "$user" "$0" $@
fi

# Second invocation with regular user
ipfs version

if [ -e "${IPFS_PATH}/config" ]; then
  echo "Found IPFS fs-repo at ${IPFS_PATH}"
else
  ipfs init
  ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001
  ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080
  cp /usr/local/bin/swarm.key  ${IPFS_PATH}/swarm.key
fi

ipfs daemon --migrate=true &
sleep 15

ipfs-cluster-service --version

if [ -e "${IPFS_CLUSTER_PATH}/service.json" ]; then
    echo "Found IPFS cluster configuration at ${IPFS_CLUSTER_PATH}"
else
    ipfs-cluster-service init --consensus "${IPFS_CLUSTER_CONSENSUS}"
    sed -i -e s/127.0.0.1/0.0.0.0/g ${IPFS_CLUSTER_PATH}/service.json
    sed -i 4c '    "secret": "d2b0fb2c1efc772e5720c0f659bffa0fb800efcdebc8c7e9b94c183f2a285546",' ${IPFS_CLUSTER_PATH}/service.json
fi

exec ipfs-cluster-service $@
