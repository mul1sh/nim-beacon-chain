#!/bin/bash

# https://github.com/koalaman/shellcheck/wiki/SC2034
# shellcheck disable=2034
true

PWD_CMD="pwd"
# get native Windows paths on Mingw
uname | grep -qi mingw && PWD_CMD="pwd -W"

cd "$(dirname "$0")"

SIM_ROOT="$($PWD_CMD)"

# Set a default value for the env vars usually supplied by a Makefile
cd "$(git rev-parse --show-toplevel)"
: ${GIT_ROOT:="$($PWD_CMD)"}
cd - &>/dev/null

# When changing these, also update the readme section on running simulation
# so that the run_node example is correct!
NUM_VALIDATORS=${VALIDATORS:-128}
TOTAL_NODES=${NODES:-4}
TOTAL_USER_NODES=${USER_NODES:-0}
TOTAL_SYSTEM_NODES=$(( TOTAL_NODES - TOTAL_USER_NODES ))
BOOTSTRAP_NODE=$(( TOTAL_NODES - 1 ))
USE_BN_VC_VALIDATOR_SPLIT=${BN_VC_VALIDATOR_SPLIT:-yes}

SIMULATION_DIR="${SIM_ROOT}/data"
METRICS_DIR="${SIM_ROOT}/prometheus"
VALIDATORS_DIR="${SIM_ROOT}/validators"
SECRETS_DIR="${SIM_ROOT}/secrets"
SNAPSHOT_FILE="${SIMULATION_DIR}/state_snapshot.ssz"
NETWORK_BOOTSTRAP_FILE="${SIMULATION_DIR}/bootstrap_nodes.txt"
BEACON_NODE_BIN="${GIT_ROOT}/build/beacon_node"
VALIDATOR_CLIENT_BIN="${GIT_ROOT}/build/validator_client"
DEPOSIT_CONTRACT_BIN="${GIT_ROOT}/build/deposit_contract"
BOOTSTRAP_ENR_FILE="${SIMULATION_DIR}/node-${BOOTSTRAP_NODE}/beacon_node.enr"
NETWORK_METADATA_FILE="${SIMULATION_DIR}/network.json"
DEPOSITS_FILE="${SIMULATION_DIR}/deposits.json"

if [[ "$USE_GANACHE" == "yes" ]]; then
  WEB3_ARG="--web3-url=ws://localhost:8545"
else
  WEB3_ARG=""
fi

BASE_P2P_PORT=30000
BASE_RPC_PORT=7000
BASE_METRICS_PORT=8008

