# CillarCoin Whitepaper

## Introduction

CillarCoin ($CILLAR) is a digital utility token developed to power seamless transit payments across the AfrailX™ and ArailX™ smart mobility systems. CillarCoin enables users to buy tickets via the Abba App—a fintech superapp developed by Abba Platforms Inc.—making it the core medium for accessing clean, efficient, and affordable mass transit in the Abba Mobility Ecosystem.

This whitepaper outlines the architecture, use cases, technical specifications, and economic model of CillarCoin. Designed with utility and programmability in mind, CillarCoin also integrates regional fare logic, dynamic rewards, refund logic, KYC compliance, and CO₂ savings tracking—helping riders save time, cost, and environmental impact.

## Websites and Developer Info

-   Website: [https://cillar.io](https://cillar.io)
-   Website: [https://afrx.io](https://afrx.io)
-   Website: [https://afrail.xyz](https://afrail.xyz)
-   Platform: [https://abbapp.com](https://abbapp.com)
-   Creator & Developer: Simon Kapenda, Founder & CTO (AFRX, Abba Platforms Inc., & Afrail Inc.)

## Purpose

CillarCoin was created to enable real-time fare payment across all transit services under Afrail Inc., including AfrailX (Africa and MENA) and ArailX (U.S. and beyond). It will be the only token used within the Abba App to pay for all forms of mobility services—rail, bus, ferry, or autonomous pods—making it an integral programmable utility token of clean smart mobility for the Global South and beyond.

CillarCoin is not an investment or speculative token. It is purely a utility token used for transit payments, programmable logic, fare distribution, and sustainability tracking.

## Tokenomics

-   **Token Name:** CillarCoin
-   **Ticker Symbol:** CILLAR
-   **Type:** Utility Token
-   **Standard:** ERC-20 (with extended logic for reward/refund/fare compliance)
-   **Blockchain:** BNB Smart Chain
-   **Total Supply:** 40 billion (40,000,000,000)
-   **Max Supply Cap:** 100 billion (100,000,000,000)
-   **Decimals:** 18
-   **Initial Price per Token:** $0.10 (USD)
-   **Public Treasury Allocation:** 45%
-   **Founders & Team Allocation:** 25%
-   **Locked and Vested Supply:** 30% (via CillarVesting contract)

## Key Smart Contract Features

### 1. Fare Payments

CillarCoin can be used to pay for one-way or return trips. Transit fares are calculated based on regional zone logic via the FareRegistry contract and converted into token equivalent based on the current USD/CILLAR price.

### 2. KYC Compliance

All riders must pass KYC (Know Your Customer) verification before transacting. The KYC expiration is enforced within the contract.

### 3. FareRegistry Integration

Different fare prices apply for local vs long-distance travel. The FareRegistry contract supports multiple regions and fallback defaults.

### 4. Refund Mechanism

Riders may be refunded if certain operator-defined conditions are met within a 48-hour refund window.

### 5. Rewards System

Every 20 eligible rides above a fare threshold will reward the user with 1 free ride (in token form). This is designed to encourage loyalty.

### 6. Subscription Logic

Operators can configure access tiers (e.g., unlimited monthly rides or senior discounts) and track subscriptions in real-time.

### 7. CO₂ Emission Savings

Each ride is tracked with its environmental offset. The default saving is 0.25kg CO₂ per ride. This helps users track their sustainability impact.

### 8. Treasury Logic

All fares collected route a portion (default 10%) to a treasury address, enabling DAO-style sustainability or reinvestment logic.

## Secondary Market & Wallet Compatibility

CillarCoin can be traded on secondary markets and is compatible with most ERC-20 wallets including MetaMask, Trust Wallet, and others. However, its exclusive use for transit payments will be inside the Abba App.

## Discounts & Benefits

-   **Senior Citizens** and **Students**: Custom fares available and enforced via FareRegistry.
-   **Subscribers**: Unlimited access plans configurable.
-   **Reward Holders**: Eligible for free tokens after ride thresholds.

## Conversion of Fiat to Stablecoin to Cillar

Users can convert local fiat currencies into stablecoins (e.g., USDT, BUSD) and swap for CillarCoin within the Abba App. This bridges the gap for unbanked and underbanked communities to access modern transit systems with a few taps.

## Governance and Ownership

CillarCoin is maintained and governed by Abba Platforms Inc., with core development led by Simon Kapenda. Token economics and smart contract logic are publicly available under MIT License.

## Cillar DAO and Hybrid Governance

CillarCoin will transition into a community-governed protocol under the formation of the **CillarDAO**. Governance will be hybrid:

-   **Protocol Layer**: Controlled by core developers and platform maintainers for smart contract upgrades and security.
-   **Community Layer**: $CILLAR holders may vote on proposals affecting treasury allocation, sustainability initiatives, and feature rollouts.

Voting rights and governance mechanisms will be defined in a future smart contract module.

## Holder Benefits (Updated)

-   **Ride Rewards**: Loyalty logic grants token rewards after every 20 rides.
-   **Refund Assurance**: Smart contract refunds for qualifying cancelations.
-   **Subscription Perks**: Early access to prepaid ride packages and monthly discounts.
-   **Governance**: DAO governance rights for eligible holders.
-   **Upside Exposure**: Holders may benefit from future secondary market listings.

## License and Ownership

-   **License:** MIT
-   **Copyright:** © 2025 Abba Platforms Inc.
-   **Created and Developed by:** Simon Kapenda
-   **Maintained by:** Abba Platforms Inc.

## Roadmap

-   **Phase 1 (2Q 2026):** Initial rollout of AfrailX in Northern Namibia + CillarCoin launch
-   **Phase 2 (3Q 2027):** Integration into Luanda (Angola) and regional scaling
-   **Phase 3 (3Q 2028):** Expansion to Nairobi, Kampala, and Lagos
-   **Phase 4 (2Q 2030+):** Global integrations + sustainability tracking + CillarDAO

## Smart Contract Upgradeability _(New)_

CillarCoin smart contracts are designed to support upgradeability patterns (e.g., UUPS) and external configuration hooks without redeployments. This improves resilience and ensures long-term extensibility.

## Roles & Permissions _(New)_

Role

Responsibility

DEFAULT_ADMIN_ROLE

Master control and emergency authority

OPERATOR_ROLE

Transit refunds, ride data entry

KYC_ADMIN_ROLE

Manage identity verifications

REWARD_ADMIN_ROLE

Adjust reward policy

## Audit Readiness _(New)_

All contracts have been refactored and hardened for enterprise-grade deployment:

-   Uses OpenZeppelin libraries and Solidity ^0.8.20
-   Audit tools compatible (Slither, MythX, CertiK-ready)
-   All logic tested with fail-safes and modifiers

## Roadmap Reference _(New)_

📍 [docs/roadmap.md](../docs/ROADMAP.md)

----------

_This document serves as the official whitepaper for CillarCoin. Please consult the CillarCoin GitHub Repository for the latest source code and documentation._
