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

  const address = "0x9097b8a7B29E81dd668dC6CC7377F8C51Bc52453";
  const secretNumber= 11

  // Create deployer object and load the artifact of the contract you want to deploy.
  const deployer = new Deployer(hre, wallet);

  
  const artifact = await deployer.loadArtifact("contracts/flat/ZKGuess.sol:ZKGuess");

  // Estimate contract deployment fee
  const deploymentFee = await deployer.estimateDeployFee(artifact, [address, secretNumber]);
  console.log(`Deployment Fee ${deploymentFee}`);


  // Deploy this contract. The returned object will be of a `Contract` type, similarly to ones in `ethers`.
  // `greeting` is an argument for contract constructor.
  const parsedFee = ethers.utils.formatEther(deploymentFee.toString());
  console.log(`The deployment is estimated to cost ${parsedFee} ETH`);

  const tokenContract = await deployer.deploy(artifact, [address, secretNumber]);

  //obtain the Constructor Arguments
  console.log("constructor args: " + tokenContract.interface.encodeDeploy([address, secretNumber]));

  // Show the contract info.
  const contractAddress = ethers.utils.getAddress(tokenContract.address);
  console.log(`${artifact.contractName} was deployed to ${contractAddress}`);
  
  }
