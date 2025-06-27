// File: utils/validators.js

import { ethers } from "ethers";

export function isValidAddress(address) {
  return ethers.utils.isAddress(address);
}

export function isPositiveNumber(value) {
  const number = Number(value);
  return !isNaN(number) && number > 0;
}

export function isNonZeroBigNumber(bn) {
  return bn && !bn.isZero();
}

export function isFutureTimestamp(timestamp) {
  return timestamp > Math.floor(Date.now() / 1000);
}

export function isNonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

export function isValidPercentage(value) {
  const num = Number(value);
  return !isNaN(num) && num >= 0 && num <= 100;
}
