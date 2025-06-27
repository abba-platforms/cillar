// File: utils/web3.js

import { ethers } from "ethers";

export function getProvider() {
  if (typeof window.ethereum !== "undefined") {
    return new ethers.providers.Web3Provider(window.ethereum);
  } else {
    throw new Error("MetaMask is not installed");
  }
}

export async function getSigner() {
  const provider = getProvider();
  await provider.send("eth_requestAccounts", []);
  return provider.getSigner();
}
