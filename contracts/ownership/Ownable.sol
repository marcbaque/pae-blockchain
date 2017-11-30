pragma solidity ^0.4.15;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address (artistic island) and the subowner (event), and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

  address public owner;
  address public subowner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(tx.origin == owner);
    _;
  }

  /**
   * @dev Throws if called by any account other than subowners or the owner.
   */
  modifier onlySubowner() {
      require(msg.sender == subowner || tx.origin == owner);
      _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}