
// File: utils/contracts.js

import { ethers } from "ethers";
import { getSigner } from "./web3";
import {
  CILLAR_ADDRESS,
  FARE_REGISTRY_ADDRESS,
  VESTING_ADDRESS,
} from "./constants";

// Import ABIs (update with actual paths in your project)
import CillarABI from "../abis/CillarCoin.json";
import FareRegistryABI from "../abis/FareRegistry.json";
import VestingABI from "../abis/CillarVesting.json";

export async function getCillarContract() {
  const signer = await getSigner();
  return new ethers.Contract(CILLAR_ADDRESS, CillarABI, signer);
}

export async function getFareRegistryContract() {
  const signer = await getSigner();
  return new ethers.Contract(FARE_REGISTRY_ADDRESS, FareRegistryABI, signer);
}

export async function getVestingContract() {
  const signer = await getSigner();
  return new ethers.Contract(VESTING_ADDRESS, VestingABI, signer);
}
