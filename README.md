This is a smart contract for the ERC1155 token standard, which is used to create and manage non-fungible tokens (NFTs). The contract allows for the creation of a Kunn card NFT that can be purchased during an early access sale or a public sale.

Functionality
The Kunn contract includes the following functionality:

Minting of new Kunn card NFTs for a price of 1 BNB per card.
Early access sale of Kunn card NFTs, limited to a maximum of 500 cards.
Public sale of Kunn card NFTs, limited to a maximum of 2000 cards.
Maximum of 2 Kunn card NFTs per transaction.
Maximum of 1 transaction during early access sale, and maximum of 2 transactions during public sale.
Merkle tree verification of purchases to prevent fraud.
Burn function to destroy Kunn card NFTs.
Maximum supply of 2000 Kunn card NFTs.
Usage
To use the Kunn contract, you will need to deploy it on the Ethereum network. You will also need to set the Merkle root for the Merkle tree verification of purchases.

Once the contract is deployed, users can mint new Kunn card NFTs by calling the mint function and sending 1 BNB with the transaction. Early access sale and public sale can be performed by calling the earlyAccessSale and purchase functions, respectively.

Early Access and Public Sale Windows
The early access sale window for Kunn card NFTs opens on March 6th, 6 pm, and closes on March 10th, 6 pm. The public sale window opens on March 10th, 6 pm, and closes on March 31st, 6 pm.

License
This contract is licensed under the MIT license.
