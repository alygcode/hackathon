// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/*
* @title ERC1155 token for Kunn cards
* @author Aly Ghoneim
*/

// Contract Kunn is a contract that implements the ERC1155 token standard
contract Kunn is ERC1155 {
    // Import the Counter library from OpenZeppelin
    using Counters for Counters.Counter;

    // Keep track of the number of tokens that have been minted
    Counters.Counter private _tokenIds;

    // Maximum number of tokens that can be minted in total
    uint256 public constant MAX_SUPPLY = 2000;

    // Maximum number of tokens that can be sold during the early access sale
    uint256 public constant MAX_EARLY_ACCESS = 500;

    // Maximum number of tokens that can be purchased in a single transaction
    uint8 public constant MAX_PER_TX = 2;

    // Maximum number of transactions that a public user can make during the public sale
    uint8 public constant MAX_TX_PUBLIC = 2;

    // Maximum number of transactions that an early access user can make during the early access sale
    uint8 public constant MAX_TX_EARLY = 1;

    // Price of each token in ether
    uint256 public constant MINT_PRICE = 1 ether;

    // ID of the token that is being minted
    uint256 public constant CARD_ID_TO_MINT = 1;

    // Timestamp for the opening of the early access sale
    uint256 public earlyAccessWindowOpens = 1646612400; // March 6th, 6 pm

    // Timestamp for the opening of the public sale
    uint256 public purchaseWindowOpens = 1646958000; // March 10th, 6 pm

    // Timestamp for the close of the public sale
    uint256 public purchaseWindowCloses = 1651398000; // March 31st, 6 pm

    // Root of the Merkle tree that is used to verify the authenticity of purchases
    bytes32 public merkleRoot;

    // Keep track of the number of transactions that each user has made
    mapping(address => uint256) public purchaseTxs;

    // Contract constructor that sets the URI and Merkle root for the contract
    constructor(string memory uri, bytes32 _merkleRoot) ERC1155(uri) {
        merkleRoot = _merkleRoot;
    }


/**
 * Function to mint new tokens.
 * 
 * @dev This function allows the caller to mint new tokens of type CARD_ID_TO_MINT and an additional unique token id.
 * @param account The address to which the tokens will be minted.
 * @return Returns the new unique token id that was minted.
 */
function mint(address account) public payable returns (uint256) {
    // Check if the maximum supply of CARD_ID_TO_MINT has been reached
    require(totalSupply(CARD_ID_TO_MINT) < MAX_SUPPLY, "Max supply reached");

    // Check if the correct amount of payment is sent with the transaction
    require(msg.value == MINT_PRICE, "Incorrect payment");

    // Increment the token id counter
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();

    // Mint 1 token of type CARD_ID_TO_MINT and 1 token of the new unique id
    _mint(account, CARD_ID_TO_MINT, 1, "");
    _mint(account, newItemId, 1, "");

    // Return the new unique token id
    return newItemId;
}


   /**
    * @dev Function to perform early access sale of the token.
    * 
    * @param amount Number of tokens to purchase.
    * @param index Index of the item in the Merkle proof.
    * @param merkleProof Merkle proof of the item in the sale list.
    */
   function earlyAccessSale(
       uint256 amount,
       uint256 index,
       bytes32[] calldata merkleProof
   ) external payable {
       // Check if the sale window is open for early access
       require(block.timestamp >= earlyAccessWindowOpens && block.timestamp <= purchaseWindowCloses, "Sale window closed");
       // Check if the maximum limit for early access sale has been reached
       require(totalSupply(0) + amount <= MAX_EARLY_ACCESS, "Max early access supply reached");
       // Check if the maximum number of transactions for the caller has been reached
       require(purchaseTxs[msg.sender] < MAX_TX_EARLY , "Max early access tx amount exceeded");
   
       // Generate the node to verify in the Merkle proof
       bytes32 node = keccak256(abi.encodePacked(index, msg.sender, uint256(2)));
       // Verify the Merkle proof
       require(
           merkleProof.length > 0 && MerkleProof.verify(merkleProof, merkleRoot, node),
           "Invalid proof"
       );
   
       // Call the internal purchase function to perform the sale
       _purchase(amount);
   }
   

   /**
    * purchase function allows a user to purchase a Kunn card.
    * 
    * @param amount the number of cards to purchase.
    */
   function purchase(uint256 amount) external payable {
           /**
            * Check if the current block timestamp is within the purchase window. If it is not, the function will
            * throw an error with the message "Sale window closed".
            */
           require(block.timestamp >= purchaseWindowOpens && block.timestamp <= purchaseWindowCloses, "Sale window closed");
           /**
            * Check if the number of transactions made by the sender is less than the max allowed public transactions.
            * If it is not, the function will throw an error with the message "Max public tx amount exceeded".
            */
           require(purchaseTxs[msg.sender] < MAX_TX_PUBLIC , "Max public tx amount exceeded");
   
           /**
            * Call the private function _purchase with the specified amount.
            */
           _purchase(amount);
       }
   

    /**
     * _purchase is a private function for purchasing the Kunn card
     *
     * @param amount The amount of Kunn cards to purchase
     */
    function _purchase(uint256 amount) private {
        // Require that the amount is greater than 0 and less than or equal to the maximum allowed per transaction
        require(amount > 0 && amount <= MAX_PER_TX, "Purchase amount prohibited");
        // Require that the total supply of Kunn cards, including the amount to be purchased, is less than the maximum supply
        require(totalSupply(CARD_ID_TO_MINT) + amount <= MAX_SUPPLY, "Max supply reached");
        // Require that the value of the transaction is equal to the amount of Kunn cards being purchased multiplied by the price per card
        require(msg.value == amount * MINT_PRICE, "Incorrect payment" );
    
        // Increment the number of transactions made by the sender
        purchaseTxs[msg.sender] += 1;
    
        // Increment the total number of Kunn cards and get the new card's ID
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        // Mint the Kunn card with ID CARD_ID_TO_MINT and the new Kunn card with the new ID
        _mint(msg.sender, CARD_ID_TO_MINT, 1, "");
        _mint(msg.sender, newItemId, amount, "");
    
        // Emit two TransferSingle events to indicate the transfer of the Kunn cards to the sender
        emit TransferSingle(msg.sender, address(0), msg.sender, CARD_ID_TO_MINT, 1);
        emit TransferSingle(msg.sender, address(0), msg.sender, newItemId, amount);
    }
    

}