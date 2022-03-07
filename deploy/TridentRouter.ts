import { BENTOBOX_ADDRESS, WNATIVE_ADDRESS } from "@sushiswap/core-sdk";

import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deployFunction: DeployFunction = async function ({
  ethers,
  deployments,
  getNamedAccounts,
  getChainId,
  run,
}: HardhatRuntimeEnvironment) {
  // console.log("Running TridentRouter deploy script");
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  const chainId = Number(await getChainId());

  let bentoBoxV1Address;
  let wethAddress;

  if (chainId === 31337) {
    // for testing purposes we use a redeployed bentobox address
    bentoBoxV1Address = (await ethers.getContract("BentoBoxV1")).address;
    wethAddress = (await ethers.getContract("WETH9")).address;
  } else {
    if (!(chainId in WNATIVE_ADDRESS)) {
      throw Error(`No WETH on chain #${chainId}!`);
    } else if (!(chainId in BENTOBOX_ADDRESS)) {
      throw Error(`No BENTOBOX on chain #${chainId}!`);
    }
    bentoBoxV1Address = BENTOBOX_ADDRESS[chainId];
    wethAddress = WNATIVE_ADDRESS[chainId];
  }

  const masterDeployer = await ethers.getContract("MasterDeployer");

  const { address, newlyDeployed } = await deploy("TridentRouter", {
    from: deployer,
    args: [bentoBoxV1Address, masterDeployer.address, wethAddress],
    deterministicDeployment: false,
    waitConfirmations: process.env.VERIFY_ON_DEPLOY === "true" ? 5 : undefined,
  });

  if (newlyDeployed && process.env.VERIFY_ON_DEPLOY === "true") {
    await run("verify:verify", {
      address,
      constructorArguments: [bentoBoxV1Address, masterDeployer.address, wethAddress],
      contract: "contracts/TridentRouter.sol:TridentRouter",
    });
  }

  // console.log("TridentRouter deployed at ", address);
};

export default deployFunction;

deployFunction.dependencies = ["MasterDeployer"];

deployFunction.tags = ["TridentRouter"];
