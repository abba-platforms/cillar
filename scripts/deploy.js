const hre = require("hardhat");

async function main() {
  const CillarCoin = await hre.ethers.getContractFactory("CillarCoin");
  const cillar = await CillarCoin.deploy();
  await cillar.deployed();

  console.log("✅ CillarCoin deployed to:", cillar.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
