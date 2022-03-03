# include .env file and export its env vars
# (-include to ignore error if it does not exist)-include .env
-include .env

# install solc version
# example to install other versions: `make solc 0_6_12`
SOLC_VERSION := 0_6_12
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_${SOLC_VERSION}

clean:; dapp clean
update:; dapp update
# Build & test
build:; dapp build
test-remote: check-api-key; dapp test --rpc-url $(call alchemy-url,goerli) # --ffi # enable if you need the `ffi` cheat code on HEVM
test-local:; ETH_RPC_URL='http://localhost:8545' dapp test --rpc  # --ffi # enable if you need the `ffi` cheat code on HEVM
flatten:; hevm flatten --source-file ${file} --json-file out/dapp.sol.json

check-api-key:
ifndef ALCHEMY_API_KEY
	$(error ALCHEMY_API_KEY is undefined)
endif

# Returns the URL to deploy to a hosted node.
# Requires the ALCHEMY_API_KEY env var to be set.
# The first argument determines the network (mainnet / rinkeby / ropsten / kovan / goerli)
define alchemy-url
https://eth-$1.alchemyapi.io/v2/${ALCHEMY_API_KEY}
endef

nodejs-deps:; yarn install
lint:; yarn run lint
