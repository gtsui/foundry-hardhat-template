import { HardhatRuntimeEnvironment } from 'hardhat/types';

const CONTRACT = "UniswapV3Adapter";

//NOTE: CONTRACT_LABEL may be different from name of contract artifact
const CONTRACT_LABEL = "UniswapV3Adapter";

const deployer = async (hre: HardhatRuntimeEnvironment) => {

  const { ethers, deployments } = hre;
  const { deploy } = deployments;

  const zimaRouter = await ethers.getContract("ZimaRouter");

  let network = hre.hardhatArguments.network == undefined ? 'hardhat' : hre.hardhatArguments.network

  let uniswapV3FactoryAddr;
  let uniswapV3RouterAddr;
  if(network === "ethereum") {
    uniswapV3FactoryAddr = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
    uniswapV3RouterAddr = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
  } else if(network === "goerli") {
    uniswapV3FactoryAddr = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
    uniswapV3RouterAddr = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";    
  }
  
  let signers = await ethers.getSigners();
  let zimaRouterAddr = await zimaRouter.getAddress();
  let args = [zimaRouterAddr, uniswapV3RouterAddr];

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
      contract: "contracts/UniswapV2Adapter.sol:UniswapV3Adapter",
      constructorArguments: args
    });
  } catch(e) {
    console.log(e);
  }

  let tx1 = await zimaRouter.__addAdapter(3, contractAddr);
  await tx1.wait();
  console.log("tx1 success");
  
}

deployer.tags = [CONTRACT_LABEL];
export default deployer;
