#!/bin/bash
set -eo pipefail

source "${BASH_SOURCE%/*}/_common.sh"

deploy() {
  normalize-env-vars

  local PASSWORD="$(extract-password)"
  if [ -n "$PASSWORD" ]; then
    PASSWORD_OPT="--password=${PASSWORD}"
  fi

  check-required-etherscan-api-key

  local OUTPUT=
  # Log the command being issued, making sure not to expose the password
  log "forge create --keystore="$FOUNDRY_ETH_KEYSTORE_FILE" $(sed 's/=.*$/=[REDACTED]/' <<<"${PASSWORD_OPT}") ${@}"
  OUTPUT=$(forge create --keystore="$FOUNDRY_ETH_KEYSTORE_FILE" ${PASSWORD_OPT} "$@" | tee >(cat 1>&2))

  grep -i 'deployed to:' <<<"$OUTPUT" | awk -F: '{ print $2 }' | tr -d '\s'
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
forge-deploy.sh [<file>:]<contract> [ --verify ] [ --constructor-args ...args ]

Examples:

    # Constructor does not take any arguments
    forge-deploy.sh src/MyContract.sol:MyContract --verify

    # Constructor takes (uint, address) arguments
    forge-deploy.sh src/MyContract.sol:MyContract --verify --constructor-args 1 0x0000000000000000000000000000000000000000
MSG
}

if [ "$0" = "$BASH_SOURCE" ]; then
  [ "$1" = "-h" -o "$1" = "--help" ] && {
    echo -e "\n$(usage)\n"
    exit 0
  }

  deploy "$@"
fi
