pragma solidity ^0.4.2;

import "./../ownership/Ownable.sol";

contract TicketTokenData is Ownable {

     /* Only logic contracts can interactuate with the token data */
     mapping(address => bool) logics;

     /* TicketToken basic information (constant) */
     uint16 public value;                   /* value: the price of each ticket. */
     uint8 public ticketType;               /* ticketType: the type of ticket. */
     uint16 public cap;                     /* cap: maximum number of tickets. */

     /* State variables (variable) */
     uint16 public totalSupply = 0;             /* totalSupply: number of tickets sold. */
     uint16 public totalResell = 0;             /* totalResell: number of tickets to resell. */

     mapping(address => uint16) balances;                   /* balances: (who, available tickets) */
     mapping (address => uint16) internal used;             /* used: (who, used tickets) */
     mapping (address => uint16) internal redButton;        /* used: (who, used tickets) */
     mapping (address => uint16) internal allowed;          /* allowed: (who, resalable tickets) */

     address[] internal clusterAllowedIndex;                /* Auxiliar to store the "Resellers" */


     function TicketTokenData(uint16 _cap, uint16 _value, uint8 _type) Ownable (msg.sender) {
        value = _value;
        cap = _cap;
        ticketType = _type;
     }

     modifier onlyLogic () {
        require(logics[msg.sender]);
        _;
     }

    function getCap() constant returns (uint16) {
        return cap;
    }

    function getType() constant returns (uint8) {
         return ticketType;
     }

     function getValue() constant returns (uint16) {
         return value;
     }

     function getTotalSupply() constant returns (uint16) {
         return totalSupply;
     }

     function setTotalSupply(uint16 _number) onlyLogic {
         totalSupply=_number;
     }

     function getTotalResell() constant returns (uint16) {
         return totalResell;
     }

     function setTotalResell(uint16 _number) onlyLogic {
         totalResell=_number;
     }

     function getBalance(address _addr) returns (uint16) {
        return balances[_addr];
     }

     function setBalance(address _addr, uint16 _balance) onlyLogic {
        balances[_addr] = _balance;
     }

     function getUsed(address _addr) constant returns (uint16) {
        return used[_addr];
     }

     function setUsed(address addr, uint16 _quantity) onlyLogic {
        used[addr] = _quantity;
     }

     function getRedButton(address _addr) constant returns (uint16) {
        return redButton[_addr];
     }

     function setRedButton(address addr, uint16 _quantity) onlyLogic {
        redButton[addr] = _quantity;
     }

     function getAllowed(address _addr) constant returns (uint16) {
        return used[_addr];
     }

     function setAllowed(address _addr, uint16 _quantity) onlyLogic {
        used[_addr] = _quantity;
     }

     function getAllowedClusterSize() constant returns (uint) {
        return clusterAllowedIndex.length;
     }

     function getAllowedIndexAt (uint16 i) constant returns (address){
        return clusterAllowedIndex[i];
     }

     function setAllowedIndex (address _addr) constant onlyLogic {
        clusterAllowedIndex.push(_addr);
     }

     function deleteAllowedIndexAt (uint16 i) onlyLogic {
         delete clusterAllowedIndex[i];
     }

     function addLogic(address logic) onlyOwner {
             logics[logic] = true;
     }

}
