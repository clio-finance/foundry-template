#!/bin/bash
set -eo pipefail

source "${BASH_SOURCE%/*}/_common.sh"

run_script() {
  normalize-env-vars

  local PASSWORD="$(extract-password)"
  local PASSWORD_OPT=()
  if [ -n "$PASSWORD" ]; then
    PASSWORD_OPT=(--password "$PASSWORD")
  fi

  check-required-etherscan-api-key "$@"

  local RESPONSE=
  # Log the command being issued, making sure not to expose the password
  log "forge script --json --gas-limit $FOUNDRY_GAS_LIMIT --keystore="$FOUNDRY_ETH_KEYSTORE_FILE" $(sed 's/ .*$/ [REDACTED]/' <<<"${PASSWORD_OPT[@]}")" $(printf ' %q' "$@")
  # Currently `forge create` sends the logs to stdout instead of stderr.
  # This makes it hard to compose its output with other commands, so here we are:
  # 1. Duplicating stdout to stderr through `tee`
  # 2. Extracting only the address of the deployed contract to stdout
  RESPONSE=$(forge script --json --gas-limit $FOUNDRY_GAS_LIMIT --keystore="$FOUNDRY_ETH_KEYSTORE_FILE" "${PASSWORD_OPT[@]}" "$@" | tee >(cat 1>&2))

  echo "\n\n--------\n\n" $RESPONSE
}

check-required-etherscan-api-key() {
  # Require the Etherscan API Key if --verify option is enabled
  set +e
  if grep -- '--verify' <<<"$@" >/dev/null; then
    [ -n "$FOUNDRY_ETHERSCAN_API_KEY" ] || die "$(err-msg-etherscan-api-key)"
  fi
  set -e
}

usage() {
  cat <<MSG
forge-script.sh <file>[:<contract>] [ --target-contract <contract> ] [ --sig <signature> ] [ --verify ]

Examples:

    forge-script.sh src/MyContract.sol:MyContract --verify

    forge-script.sh src/MyContract.sol --target-contract MyContract --sig 'deploy()' --verify
MSG
}

if [ "$0" = "$BASH_SOURCE" ]; then
  [ "$1" = "-h" -o "$1" = "--help" ] && {
    echo -e "\n$(usage)\n"
    exit 0
  }

  run_script "$@"
fi
