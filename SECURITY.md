# Security Policy

## 📆 Reporting a Vulnerability

If you discover a security vulnerability in the CillarCoin smart contracts or any associated components in this repository, please report it **privately and responsibly**:

-   **Email:** [security@cillar.io](mailto:security@abbaplatforms.com)
-   **PGP Key:** _(Coming Soon – to be published in `SECURITY.md`)_

Please include:

-   A clear description of the issue
-   Reproduction steps (if applicable)
-   Severity and possible impact
-   Any recommended fixes

We aim to acknowledge and triage reports within **72 hours**, and we’ll work with you to validate, fix, and credit the issue appropriately (if desired).

----------

## 🔐 Supported Versions

We currently maintain security updates for:

Contract

Version

Status

`CillarCoin.sol`

v1.0.6

✅ Maintained

`CillarVesting.sol`

v1.0.6

✅ Maintained

`FareRegistry.sol`

v1.0.6

✅ Maintained

----------

## 🧪 Security Practices

-   Role-based access control using OpenZeppelin `AccessControl`
-   Internal audit completed (v1.0.6)
-   External audit planned (Q3 2025)
-   Treasury, refund, vesting logic tested
-   Code reviewed for integer safety, upgradability, and owner privileges

----------

## 🧰 Helpful Resources

-   [AUDIT.md](./AUDIT.md) – Full audit preparation and disclosure log
-   [README.md](./README.md) – Project overview
-   [WHITEPAPER.md](./docs/WHITEPAPER.md) – Technical vision and design

----------

Thank you for helping make CillarCoin secure! 🙏

— Simon Kapenda (Founder, Abba Platforms Inc.)
