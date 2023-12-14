import { HardhatRuntimeEnvironment } from 'hardhat/types';

const CONTRACT = "ZimaRouter";

//NOTE: CONTRACT_LABEL may be different from name of contract artifact
const CONTRACT_LABEL = "ZimaRouter";

const deployer = async (hre: HardhatRuntimeEnvironment) => {

  const { ethers, deployments } = hre;
  const { deploy } = deployments;

  let signers = await ethers.getSigners();
  let args = [signers[0].address];

  await deploy(
    CONTRACT_LABEL,
    {
      from: signers[0].address,
      contract: CONTRACT,
      args: args,
      log: true,
      proxy: false
    }
  );
  
  const contract = await ethers.getContract(CONTRACT_LABEL);
  const contractAddr = await contract.getAddress();

  try {
    await hre.run("verify:verify", {
      address: contractAddr,
      contract: "contracts/ZimaRouter.sol:ZimaRouter",
      constructorArguments: args
    });
  } catch(e) {
    console.log(e);
  }
  
}

deployer.tags = [CONTRACT_LABEL];
export default deployer;
