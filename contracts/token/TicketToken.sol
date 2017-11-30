pragma solidity ^0.4.15;

import '../math/SafeMath.sol';
import './ERC20.sol'
import '../lifecycle/Pausable.sol'

/**
 * @title TicketToken
 * @dev Version of ERC20 Token, representing tickets for an event.
 */

contract TicketToken is ERC20, Pausable {
    using SafeMath for uint256;

    event Resell(address from, uint256 value);

    uint256 value;
    string type;

    uint256 public totalSupply;
    uint256 internal totalResell;
    unit256 internal totalUsed;
    uint256 public cap;

    mapping(address => uint256) balances;
    mapping (address => uint256) internal used;
    mapping (address => uint256) internal allowed;

    address[] internal clusterAllowedIndex;

    function TicketToken(uint _cap, uint _value, string _type, address _owner) {
        cap = _cap;
        owner = _owner;
        subowner = msg.sender;
        value = _value;
        type = _type;
        totalSupply = 0;
        totalResell = 0;
        totalUsed = 0;
    }

    /**
     * @dev Gets the supply of tickets sold.
     * @return An uint256 representing the amount of tickets sold.
     */

    function totalSupply() constant returns (uint totalSupply) {
        return totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount of tickets owned by the passed address.
     */

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */

     function transfer(address _to, uint256 _value) public onlySubowner whenNotPaused returns (bool) {
       require(_to != address(0));
       require(_value <= balances[tx.origin]);
       balances[tx.origin] = balances[tx.origin].sub(_value);
       balances[_to] = balances[_to].add(_value);
       return true;
     }

     /**
      * @dev Transfer tokens from one address to another
      * @param _from address The address which you want to send tokens from
      * @param _to address The address which you want to transfer to
      * @param _value uint256 the amount of tokens to be transferred
      */

     function transferFrom(address _from, address _to, uint _value) onlySubowner whenNotPaused returns (bool success) {
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

       function approve(uint256 _value) public onlySubowner whenNotPaused returns (bool) {
           require(_value <= balances[tx.origin]);
           if (allowed[tx.origin] = 0) { clusterAllowedIndex.push(tx.origin) }
           allowed[tx.origin] = _value;
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

      function assignTickets(address _to, uint _number) onlySubowner notPaused {
          require(cap - totalSupply + totalResell >= _number)
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

      function useTicket() notPaused {
          require(balances[tx.origin] > 0);
          balances[tx.origin] -= 1;
          if (allowance[tx.origin] > balances[tx.origin]) allowance[msg.sender] = balances[tx.origin];
          totalUsed += 1;

      }

}