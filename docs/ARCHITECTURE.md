## System Architecture Overview

CillarCoin operates as a smart, utility-based digital token that integrates with various components of the Abba Ecosystem, especially for use within the AfrailX and ArailX transit systems. The architecture below outlines how CillarCoin functions within this ecosystem.

----------

### 🚏 Architecture Diagram (Simplified)

```text
+-------------------+         +----------------------+        +--------------------+
|   Abba App (UI)   +-------->+  CillarCoin Smart    +<------>+ FareRegistry Smart |
| (Mobile/Web)      |         |  Contract (BNB Chain)|        |   Contract         |
+--------+----------+         +----------+-----------+        +----------+---------+
         |                               |                               |
         |                               v                               v
         |                 +--------------------------+     +------------------------+
         |                 |  Treasury & Vesting Logic|     |  KYC + Ride Logic      |
         |                 |  (CillarVesting.sol)     |     | (CillarCoin.sol)       |
         |                 +------------+-------------+     +------------------------+
         |                              \/
         |                        Rewards + Fares
         |                              \/
         +----------------> User Ride Flow & Incentives

```

----------

### 🔗 Resources

-   **View README**: [README.md](../README.md)
-   **Whitepaper**: [WHITEPAPER.md](../docs/WHITEPAPER.md)

----------

### 📬 Contact

For technical inquiries or contribution proposals: **Email**: [support@cillar.io](mailto:support@cillar.io)

----------

### 📌 Notes

-   This diagram serves as a high-level visual of how the core smart contracts interconnect.
-   The system ensures modularity, decentralization, and upgradability for future enhancements.
