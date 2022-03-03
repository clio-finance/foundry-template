# Dapp Template

Template for Smart Contract applications compatible with dapp.tools or foundry.

## Usage

### Install dependencies

```bash
# Install tools from the nodejs ecosystem: prettier, solhint, husky and lint-staged
make nodejs-deps
# Install smart contract dependencies through `dapp update`
make update
```

### Create a local `.env` file and change the placeholder values

```bash
cp .env.examples .env
```

### Build contracts

```bash
make build
```

### Test contracts

```bash
make test-local # using a local node listening on http://localhost:8545
make test-remote # using a remote node (alchemy). Requires ALCHEMY_API_KEY env var.
```
