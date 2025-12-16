<!-- markdownlint-disable MD022 MD024 -->
# Spacebear NFT (Foundry)

Professional implementation of the Spacebear ERC-721 contract (see the tutorial at https://www.ethereum-blockchain-developer.com/courses/ethereum-course-2024/project-erc721-nft-with-remix-truffle-hardhat-and-foundry/deploy-smart-contracts-using-foundry) using the Foundry stack, deployed to Sepolia with `forge script`.

## 1. Overview

- **Contract:** `Spacebear` (ERC-721 non-fungible token with owner-only `safeMint` and payable `buyToken` logic).
- **Stack:** Foundry (`forge`, `cast`, `anvil`) with OpenZeppelin's `ERC721`, `Ownable`, `Counters`, and `Strings`.
- **Network:** Sepolia testnet (contract address `0xb3a46d81ed4f2fda543ef5f164109b0db398605e`; deployment transaction `0x1eda08a9b9d5a8b31778cdc32f3287bccbcf5cf5a86422bf4cad4efef758be67` recorded in `broadcast/Deploy.sol/11155111/run-latest.json`).
- **Deployment script:** `script/Deploy.sol` reads a mnemonic from `.secret`, derives the private key, opens a broadcast, deploys `Spacebear`, and then stops broadcasting via `vm.startBroadcast` and `vm.stopBroadcast`.

## 2. Prerequisites

1. Install Foundry by following the official guide at https://book.getfoundry.sh/getting-started/installation.
2. Duplicate `.env.example` (if available) or create `.env` with your network credentials:

   ```env
   SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/<PROJECT_ID>
   ETHERSCAN_API_KEY=<your_key>
   ```

3. Store your wallet mnemonic (12 or 24 words) in `.secret` so the deployment script can derive a private key locally.
4. Run `foundryup` whenever the toolchain is bumped; this project targets Solidity `^0.8.30`.

## 3. Repository Layout

| Directory | Purpose |
| --- | --- |
| `src/` | Solidity contracts (`Spacebear.sol`). |
| `script/` | Deployment script (`SpacebearScript`). |
| `broadcast/` | Forge output for each `forge script --broadcast`, including receipts and gas data. |
| `test/` | Forge test suite (extend this with more coverage for minting and payments). |
| `out/` | Compiled artifacts and ABI/bytecode exports. |
| `foundry.toml` | Project configuration (compiler version, output paths, RPC endpoints, fs permissions). |

The contract currently returns a fixed base URI to match the tutorial assets.

## 4. Foundry Command Flow

Replace `<command>` with the command you intend to run for the current task.

- `forge build` - compile contracts and store artifacts in `out/`.
- `forge fmt` - format Solidity source files.
- `forge snapshot` - record gas usage snapshots for regression tracking.
- `forge test` - execute all tests under `test/`.
- `forge test --match-path src/Spacebear.sol` - focus on regressions inside the NFT contract.
- `cast --help` / `forge --help` - display command and subcommand references.
- `anvil` - launch a local EVM for fast prototyping and script development.

## 5. Deployment to Sepolia

Deployment is handled by the tutorial-aligned script inside `script/Deploy.sol`. Run the following command after sourcing your `.env` so `SEPOLIA_RPC_URL` and `ETHERSCAN_API_KEY` are available:

```powershell
forge script script/Deploy.sol:SpacebearScript `
  --rpc-url sepolia `
  --broadcast `
  --verify `
  --etherscan-api-key $env:ETHERSCAN_API_KEY
```

This command:

1. Resolves `sepolia` from `foundry.toml` (`SEPOLIA_RPC_URL` is substituted via the `[rpc_endpoints]` section).
2. Loads the mnemonic from `.secret`, derives a private key, and begins broadcasting on Sepolia.
3. Outputs the receipt and metadata to `broadcast/Deploy.sol/11155111/run-latest.json`.
4. Sends verification data to Etherscan while the transaction is finalizing.

You can rerun the script to redeploy (the `broadcast/` folder will keep a timestamped record) or call `forge script` with `--skip-simulation` when you have assured the bytecode.

## 6. Interacting with the Deployed Contract

- Query owner or token data via `cast call`, for example:

  ```powershell
  cast call 0xb3a46d81ed4f2fda543ef5f164109b0db398605e ownerOf 0 --rpc-url sepolia
  ```

- Use `cast send` with the derived private key to test payable functions (`buyToken`) on Sepolia or a local Anvil node.
- When debugging locally, point `forge script` at `http://127.0.0.1:8545` after running `anvil`, and use `cast call` to check minted tokens.

## 7. Configuration Notes

- `foundry.toml` currently exposes Sepolia via:

  ```toml
  [rpc_endpoints]
  sepolia = "${SEPOLIA_RPC_URL}"
  ```

- `fs_permissions` are scoped to the repository root for script safety.
- The default profile targets Solidity `0.8.30` and writes outputs to `out/`; adjust `[profile.default]` if you upgrade the compiler.

## 8. Next Steps

1. Add Forge tests that cover `buyToken` pricing, owner-only minting, and base URI logic.
2. Record minted tokens and sale mechanics for stakeholders who inspect the Sepolia deployment.
3. Consider a CI workflow (GitHub Actions or similar) that runs `forge fmt`, `forge test`, and `forge snapshot` before merging.

Let me know if you would like help adding CI, drafting a PR template, or deploying to another network.
