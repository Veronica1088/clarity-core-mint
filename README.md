# CoreMint NFT Platform

A decentralized platform for minting and managing NFTs on the Stacks blockchain.

## Features
- Mint new NFTs with metadata
- Transfer NFTs between accounts
- View NFT metadata
- Royalty support for creators

## Getting Started
1. Clone the repository
2. Install dependencies with `clarinet install`
3. Run tests with `clarinet test`

## Contract Interface
### Mint NFT
```clarity
(mint-nft (metadata (string-utf8 500)) (royalty uint))
```

### Transfer NFT
```clarity
(transfer-nft (token-id uint) (sender principal) (recipient principal))
```
