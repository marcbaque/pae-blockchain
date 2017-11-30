pragma solidity ^0.4.15;

import './../math/SafeMath.sol';
import './../lifecycle/Pausable.sol';

/**
 * @title TicketToken
 * @dev Version of ERC20 Token, representing tickets for an event.
 */

contract TicketToken is Pausable {
    using SafeMath for uint16;

    event Resell(address from, uint16 value);

    uint16 value;
    uint8 ticketType;

    uint16 public totalSupply;
    uint16 internal totalResell;
    uint16 internal totalUsed;
    uint16 public cap;

    mapping(address => uint16) balances;
    mapping (address => uint16) internal used;
    mapping (address => uint16) internal allowed;

    address[] internal clusterAllowedIndex;

    function TicketToken(uint16 _cap, uint16 _value, uint8 _type, address _owner) {
        cap = _cap;
        owner = _owner;
        subowner = msg.sender;
        value = _value;
        ticketType = _type;
        totalSupply = 0;
        totalResell = 0;
        totalUsed = 0;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount of tickets owned by the passed address.
     */

    function balanceOf(address _owner) constant returns (uint16 balance) {
        return balances[_owner];
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */

     function transfer(address _from, address _to, uint16 _value) public onlySubowner whenNotPaused returns (bool) {
       require(_to != address(0));
       require(_value <= balances[_from]);
       balances[_from] = balances[_from].sub(_value);
       balances[_to] = balances[_to].add(_value);
       return true;
     }

     /**
      * @dev Transfer tokens from one address to another
      * @param _from address The address which you want to send tokens from
      * @param _to address The address which you want to transfer to
      * @param _value uint256 the amount of tokens to be transferred
      */

     function transferFrom(address _from, address _to, uint16 _value) onlySubowner whenNotPaused returns (bool success) {
         require(_to != address(0));
         require(_value <= allowed[_from]);
         require(_value <= balances[_from]);
         balances[_from] = balances[_from].sub(_value);
         allowed[_from] = allowed[_from].sub(_value);
         balances[_to] = balances[_to].add(_value);
         Resell(_from, _value);
         return true;
     }

      /**
       * @dev Approve the passed address to resell the specified amount of tokens.
       */

       function approve(address _from, uint16 _value) public onlySubowner whenNotPaused returns (bool) {
           require(_value <= balances[_from]);
           if (allowed[_from] == 0) { clusterAllowedIndex.push(_from); }
           allowed[_from] = _value;
           totalResell += _value;
           return true;
       }

       /**
        * @dev Function to check the amount of tokens that an owner allowed to resell.
        * @param _owner address The address which owns the funds.
        * @return A uint256 specifying the amount of tokens still available to resell
        */

       function allowance(address _owner) public view returns (uint256) {
           return allowed[_owner];
       }

      function assignTickets(address _to, uint16 _number) public onlySubowner whenNotPaused {
          require(cap - totalSupply + totalResell >= _number);
          while (_number > 0) {
            if((totalSupply + 1) <= cap) {
                balances[_to] += 1;
                totalSupply += 1;
                _number -= 1;
            } else {
                for(uint256 i = 0; i < clusterAllowedIndex.length; i++) {
                    if(allowance(clusterAllowedIndex[i]) > 0) {
                        transferFrom(clusterAllowedIndex[i], _to, 1);
                        i -= 1; _number-=1; totalResell -= 1;
                        if (_number == 0) break;
                    } else {
                        delete clusterAllowedIndex[i];
                    }
                }
            }
          }
      }

      /**
       * @dev Function to use a owned ticket.
       */

      function useTicket() whenNotPaused {
          require(balances[tx.origin] > 0);
          balances[tx.origin] -= 1;
          if (allowed[tx.origin] > balances[tx.origin]) allowed[msg.sender] = balances[tx.origin];
          totalUsed += 1;

      }

}