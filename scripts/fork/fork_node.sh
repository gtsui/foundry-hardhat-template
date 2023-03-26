#!/bin/bash

[[ $# -ge 1 ]] && NETWORK=$1 || NETWORK="ETHEREUM"
NETWORK=$(echo $NETWORK | tr '[:lower:]' '[:upper:]')

PROVIDER_URL="${NETWORK}_PROVIDER"
BLOCK_NUMBER="${NETWORK}_FORK_BLOCK_NUMBER"

SOURCE_DIR="$(dirname "$0")/"

source "$SOURCE_DIR/../../.env"

anvil --fork-url ${!PROVIDER_URL} `### RPC URL of the blockchain to fork ###` \
      --fork-block-number ${!BLOCK_NUMBER} `### Block number of the blockchain to fork ###` \
