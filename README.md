# zkGuess

## The number guessing game where you can win BIG!
#### Or lose some ETH but thats okay.

## Details

zkGuess a simple guesing game deploy to zkSync's V2 Testnet. The point of the game is simple, theres a _secret_ number within the storage of the contract, if you can successfully guess that number, you will win __80%__ of the value held by the contract as well as __100__ GuessTokens (GT)!

The GuessTokens is a custom ERC20 contract that is very limited in supply. It has all the functionality of ERC20s, but the only important functions are the Mint and Burn functions. These allow to mint tokens to an address, and burn them to address 0x0 respectively.

ZK Guess: https://goerli.explorer.zksync.io/address/0x695248aEfebE2A5E9f1E3AEB80cA95F0FAF62BDD

GuessToken: https://goerli.explorer.zksync.io/address/0x9097b8a7B29E81dd668dC6CC7377F8C51Bc52453

## Results

If you unsuccessfully guess the number, you will see a large LOSER sign on the website - no hard feelings, its all for show.

If you successfully guess the number, congrats!! You've won and will see a large WINNER sign on the website!

## To run:

1. Clone the repo
2. Run command: `yarn` (using node 18.8.0)
3. Run `yarn hardhat compile`
4. To deploy: remove the `deploy.ts` script from the deploy folder (this is just for deploying the standalone ZKGuess contract, we dont need it.)
5. Then run `yarn hardhat deploy-zksync`

## Ideal TODO:
- TEST!! I was tight on time this week so I didnt get a chance to properly test. I have plenty of Foundry and a few HH testing examples in my GitHub.
- Better web-landing page
- Add ZK proofs to guessing
    - Use SNARKs to hide the secret number, require zkProof on guess. This will hide the secret number in the verifier and will also hide the inputs, so if someone were to be snooping on chain, they wouldnt see guesses or the secret number.
- Create the ERC20 token in the ZKGuess.sol contract and limit accessibility in the Mint function.
- Migrate to Foundry instead of HH (??)

## Issues I ran into
This is my first time deploying to zkSync and also using Vue so I went through the tutorials to start (figured this would be a good learning opportunity for both). I did however run into some odd issues which I've documented.

- First time I deployed the Greeter contract from the tutorial I had no immediate issues, everything compiled and deployed successfully. When I went to the Vue WebUI tutorial, I couldnt get the data from the contract, when I queried for the contract data it came back as `0x`, this was breaking the view method `greet()`. I spent quite a while debugging this as I had the correct address and the confirmation from the deploy script as well as the Verifier on zkSync's block explorer. Anthony suggested I redeploy the contract, so I did with a slight variation - I did a simple public `name` variable to the storage. This contract deployed to the __exact__ same address as the first one (really weird) and my UI suddenly was reading contract data. I also went through the block explorer and verified it and it worked fine as well. For reference the address is: `0xb6a400bdB96558CB8bF5287F3965bD2395a5D2E7`.

- I couldnt import the OpenZeppelin contracts the first time I went to deploy my ERC20 contract, it kept giving me a `ran out of gas` error. To fix this I squashed the Owner contract from OZ into the contract, that seemed to fix it.

- I couldnt read from my deployed contracts on the ZK Sync website - they kept failing. I messaged Anthony about it.

- I couldnt get any transactions to go through - even through the zk Sync UI.



