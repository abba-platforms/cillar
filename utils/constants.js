// File: utils/constants.js

export const BNB_MAINNET = {
  chainId: 56,
  name: "BNB Smart Chain",
  rpc: "https://bsc-dataseed.binance.org/",
  explorer: "https://bscscan.com"
};

export const BNB_TESTNET = {
  chainId: 97,
  name: "BNB Testnet",
  rpc: "https://data-seed-prebsc-1-s1.binance.org:8545/",
  explorer: "https://testnet.bscscan.com"
};

export const TOKEN_SYMBOL = "CILLAR";
export const TOKEN_NAME = "CillarCoin";
export const TOKEN_DECIMALS = 18;

// Example contract addresses — replace with real ones after deployment
export const CILLARCOIN_ADDRESS = "0x0000000000000000000000000000000000000000";
export const FARE_REGISTRY_ADDRESS = "0x0000000000000000000000000000000000000000";
export const VESTING_CONTRACT_ADDRESS = "0x0000000000000000000000000000000000000000";

export const CO2_SAVED_PER_RIDE_KG = 0.25;
export const DEFAULT_REWARD_THRESHOLD = 20;
export const DEFAULT_REWARD_AMOUNT = 1; // 1 CILLAR
export const REFUND_WINDOW_HOURS = 48;
