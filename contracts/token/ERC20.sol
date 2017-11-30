pragma solidity ^0.4.15;

/**
 * @title ERC20
 * @dev Token Standard (Transferable Fungibles)
 * @dev see https://github.com/ethereum/eips/issues/20
 */

contract ERC20 {

    function balanceOf(address _owner) constant returns (uint16 balance);
    function transfer(address _from, address _to, uint16 _value) public onlySubowner whenNotPaused returns (bool) ;
    function transferFrom(address _from, address _to, uint16 _value) onlySubowner whenNotPaused returns (bool success);
    function approve(address _from, uint16 _value) public onlySubowner whenNotPaused returns (bool);
    function allowance(address _owner) public view returns (uint256);

}