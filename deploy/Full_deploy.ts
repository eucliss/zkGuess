import { Wallet, utils } from "zksync-web3";
import * as ethers from "ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { getContractAddress } from "ethers/lib/utils";

// An example of a deploy script that will deploy and call a simple contract.
export default async function (hre: HardhatRuntimeEnvironment) {
  
  console.log(`Running deploy script for the GuessToken contract`);

  // Initialize the wallet.
  const wallet = new Wallet("<Add your private key here>");

  // Create deployer object and load the artifact of the contract you want to deploy.
  const deployer = new Deployer(hre, wallet);

  
  const artifact = await deployer.loadArtifact("contracts/flat/GuessToken.sol:GuessToken");

  // Estimate contract deployment fee
  const deploymentFee = await deployer.estimateDeployFee(artifact, []);
  console.log(`Deployment Fee ${deploymentFee}`);

  // OPTIONAL: Deposit funds to L2
  // Comment this block if you already have funds on zkSync.
  const depositHandle = await deployer.zkWallet.deposit({
    to: deployer.zkWallet.address,
    token: utils.ETH_ADDRESS,
    amount: deploymentFee.mul(2),
  });
  // Wait until the deposit is processed on zkSync
  await depositHandle.wait();

  // Deploy this contract. The returned object will be of a `Contract` type, similarly to ones in `ethers`.
  // `greeting` is an argument for contract constructor.
  const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
  console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

  const tokenContract = await deployer.deploy(artifact, []);

  //obtain the Constructor Arguments
  console.log("constructor args: " + tokenContract.interface.encodeDeploy([]));

  // Show the contract info.
  const contractAddress = ethers.utils.getAddress(tokenContract.address);
  console.log(`${artifact.contractName} was deployed to ${contractAddress}`);
  
  console.log(`Running deploy script for the zkGuess contract`);

  // _______________

  const guessArtifact = await deployer.loadArtifact("contracts/flat/ZKGuess.sol:ZKGuess");

  // const contractAddress = "0x2917426e7C957A2707CBDE6FaDBb216ba73b38aF";
  const secretNumber = 11;

  // Estimate contract deployment fee
  const fee = await deployer.estimateDeployFee(guessArtifact, [contractAddress, secretNumber]);

  // Deploy this contract. The returned object will be of a `Contract` type, similarly to ones in `ethers`.
  // `greeting` is an argument for contract constructor.
  const parsedFeeGuess = ethers.utils.formatEther(fee.toString());
  console.log(`The deployment is estimated to cost ${parsedFeeGuess} ETH`);

  const guessContract = await deployer.deploy(guessArtifact, [contractAddress, secretNumber]);

  //obtain the Constructor Arguments
  console.log("constructor args:" + guessContract.interface.encodeDeploy([contractAddress, secretNumber]));

  // Show the contract info.
  const guessAddress = guessContract.address;
  console.log(`${guessArtifact.contractName} was deployed to ${guessAddress}`);


}
