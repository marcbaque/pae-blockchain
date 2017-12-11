pragma solidity ^0.4.15;

/**
 * @title MultiOwnable
 * @dev The MultiOwnable contract has an owner address (artistic island) and the subowners , and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */

contract MultiOwnable {

  address public owner;
  mapping(address => bool) public subowner;


 /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Throws if called by any account other than subowners or the owner.
   */
  modifier onlySubowner() {
      require(subowner[msg.sender] || msg.sender == owner || msg.sender == address(this));
      _;
  }

  function MultiOwnable (address _owner, address _subowner) public {
        owner = _owner;
        subowner[_subowner] = true;
  }

  function addSubowner(address _subowner) public {
    subowner[_subowner] = true;
  }

}