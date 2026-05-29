Got it — full single complete README, no omissions.

```md
# 🪂 Merkle Airdrop Protocol (Foundry Edition)

A **secure, dual-verified token airdrop system** built with [Foundry](https://book.getfoundry.sh/), combining **Merkle Proofs + EIP-712 signatures** to ensure only eligible users can claim tokens.

This project demonstrates:
- 🔐 Cryptographically secure airdrops (Merkle Trees)
- ✍️ EIP-712 typed data signatures
- 🧾 Anti-replay + single-claim enforcement
- ⚙️ Foundry-based scripting & automation
- 🧠 Real-world airdrop architecture design

---

# 📚 Table of Contents

- [💼 Why This Project Stands Out](#-why-this-project-stands-out)
- [📁 Project Structure](#-project-structure)
- [⚙️ Getting Started](#️-getting-started)
  - [Requirements](#requirements)
  - [Clone & Build](#clone--build)
- [🧩 Core Architecture](#-core-architecture)
  - [🔐 Claim Flow](#-claim-flow)
  - [🌳 Merkle Verification](#-merkle-verification)
  - [✍️ Signature Verification (EIP-712)](#️-signature-verification-eip-712)
- [🚀 Deploying Contracts](#-deploying-contracts)
  - [🧪 Local Deployment](#-local-deployment)
- [🧪 Running Scripts](#-running-scripts)
  - [📦 Generate Input Data](#-generate-input-data)
  - [🌳 Build Merkle Tree & Proofs](#-build-merkle-tree--proofs)
  - [🪂 Claim Airdrop](#-claim-airdrop)
- [🔐 Security Considerations](#-security-considerations)
- [🧠 Concepts Covered](#-concepts-covered)
- [🔍 Project Flow Overview](#-project-flow-overview)
- [🎯 What This Project Proves](#-what-this-project-proves)
- [🧑‍💻 About](#-about)
- [📌 Notes](#-notes)
- [🧠 License](#-license)
- [⭐ Support](#-support)
- [🙏 Acknowledgment](#-acknowledgment)

---

# 💼 Why This Project Stands Out

Most airdrop systems rely on a single verification method.

This protocol enforces two independent cryptographic guarantees:

- 🌳 Merkle Proof verification → proves eligibility
- ✍️ EIP-712 signature verification → proves authorization
- 🚫 Prevents replay attacks using on-chain state tracking
- 🧾 Ensures one-time claim per address

👉 This is a **production-grade token distribution system**, not a demo.

---

# 📁 Project Structure

```

├── src/
│   └── MerkleAirdrop.sol          # Core airdrop contract
│
├── script/
│   ├── DeployMerkleAirdrop.s.sol   # Deployment script
│   ├── GenerateInput.s.sol         # Whitelist input generator
│   ├── MakeMerkle&SplitSignature.s.sol # Merkle + proof generator
│   ├── interact.s.sol              # Claim interaction script
│
├── lib/                            # Dependencies (OpenZeppelin, Murky, forge-std)
└── foundry.toml

````

---

# ⚙️ Getting Started

## Requirements

- Git
- Foundry
- Node.js (optional)

---

## Clone & Build

```bash
git clone https://github.com/your-username/merkle-airdrop
cd merkle-airdrop
forge install
forge build
````

---

# 🧩 Core Architecture

## 🔐 Claim Flow

```
User → Signature Check (EIP-712)
     → Merkle Proof Verification
     → Already Claimed Check
     → Token Transfer
```

---

## 🌳 Merkle Verification

Each leaf is constructed as:

```solidity
keccak256(abi.encode(account, amount))
```

* Leaves are double-hashed to prevent second pre-image attacks
* Merkle root generated off-chain
* Verification performed using OpenZeppelin `MerkleProof`

---

## ✍️ Signature Verification (EIP-712)

Typed structured message:

```solidity
AirdropClaim(address account, uint256 amount)
```

* Prevents unauthorized claims
* Ensures signer explicitly approves claim
* Uses `ECDSA.tryRecover` for safe recovery

---

# 🚀 Deploying Contracts

## 🧪 Local Deployment

```bash
forge script script/DeployMerkleAirdrop.s.sol \
  --broadcast \
  --private-key <PRIVATE_KEY>
```

---

# 🧪 Running Scripts

## 📦 Generate Input Data

Creates whitelist dataset for Merkle tree:

```bash
forge script script/GenerateInput.s.sol
```

Output:

```
/script/target/input.json
```

---

## 🌳 Build Merkle Tree & Proofs

Generates:

* Merkle root
* Leaf nodes
* Merkle proofs per user
* JSON output for claims

```bash
forge script script/MakeMerkle&SplitSignature.s.sol
```

---

## 🪂 Claim Airdrop

Run interaction script:

```bash
forge script script/interact.s.sol --broadcast
```

Or manual call:

```bash
cast send <AIRDROP_ADDRESS> \
"claim(address,uint256,bytes32[],uint8,bytes32,bytes32)" \
<ACCOUNT> <AMOUNT> <PROOF> <v> <r> <s>
```

---

# 🔐 Security Considerations

* Single-claim enforcement via mapping
* EIP-712 signature validation
* Merkle root immutability
* Double hashing for leaf safety
* SafeERC20 transfers
* Explicit revert errors for auditability

---

# 🧠 Concepts Covered

* Merkle Trees
* EIP-712 typed data signing
* ECDSA signature recovery
* Foundry scripting system
* Off-chain computation pipelines
* JSON data generation
* Token distribution design patterns
* Crypto verification primitives

---

# 🔍 Project Flow Overview

1. Generate whitelist input data
2. Build Merkle tree + proofs
3. Deploy token + airdrop contract
4. Mint tokens to airdrop contract
5. User submits:

   * Merkle proof
   * Signature
6. Contract verifies and transfers tokens

---

# 🎯 What This Project Proves

This project demonstrates:

* Production-grade airdrop architecture
* Strong cryptographic engineering skills
* Secure token distribution design
* Full-stack Solidity + Foundry workflow

👉 Suitable for DeFi engineering and smart contract security roles

---

# 🧑‍💻 About

Blockchain developer focused on:

* Smart contract engineering
* Protocol design
* Security-first development
* Foundry-based workflows

---

# 📌 Notes

This project is designed for secure and verifiable token distribution systems with emphasis on correctness and auditability.

---

# 🧠 License

MIT License

---

# ⭐ Support

If this project helps you, star the repository ⭐

---

# 🙏 Acknowledgment

Built with precision, discipline, and a strong focus on secure smart contract engineering.

