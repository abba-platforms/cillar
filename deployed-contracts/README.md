# ✅ CillarCoin Smart Contract Deployment Details

This document provides the full deployment details of the **CillarCoin** smart contract deployed on the **BNB Smart Chain (BSC)** mainnet. It includes metadata, verification, ABI, and timestamps for reference and auditing purposes.

----------

## 📌 Contract Overview

-   **Contract Name**: `CillarCoin`
-   **File**: `contracts/CillarCoinFlat.sol`
-   **Compiler Version**: `0.8.20`
-   **Optimization**: Enabled (200 runs)
-   **Verified on BscScan**: [Yes](https://bscscan.com/address/0x4364a697bB204C8239b40d038F500971f6fe4D37#code)

----------

## 🔗 Deployed Address

-   `0x4364a697bB204C8239b40d038F500971f6fe4D37`

## 📆 Deployment Timestamp

-   **Date**: July 8, 2025
-   **Time (UTC)**: Approximately 07:36 AM

----------

## 🧱 Constructor Arguments

```js
[
  "0xFf559344ef6450FFafCD9a5Af44387E3E8818FeE", // Treasury Address
  "0x3678f86c47c7B1dd466aCa2171992918da28db2b", // Rewards Wallet
  "0x4364a697bB204C8239b40d038F500971f6fe4D37", // Token Address
  "0x694AA1769357215DE4FAC081bf1f309aDC325306"  // Fee Recipient
]

```

----------

## 📜 ABI

```
<Insert ABI JSON Here>

```

> ℹ️ The ABI should be pasted here once exported from `artifacts/contracts/CillarCoinFlat.sol/CillarCoin.json`

----------

## 🔧 Hardhat Configuration (Excerpt)

```js
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    bsc: {
      url: "https://bsc-dataseed.binance.org",
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      bsc: process.env.ETHERSCAN_API_KEY
    },
  },
};

```

----------

## 🧾 Verification Log

Successfully verified contract `CillarCoin` on BscScan:

-   ✅ [https://bscscan.com/address/0x4364a697bB204C8239b40d038F500971f6fe4D37#code](https://bscscan.com/address/0x4364a697bB204C8239b40d038F500971f6fe4D37#code)

----------

## ✅ Notes

-   Source code flattened before verification.
-   Deployment and verification managed via Hardhat + dotenv.
-   Ensure all constructor parameters are accurate and ABI is up to date.

----------

Created and developed by: **Simon Kapenda**, Creator of **Abba App** and Founder & CTO, **Afrail Inc.**
Maintained by: **Abba Platforms Inc.**  
Date: **July 8, 2025**
