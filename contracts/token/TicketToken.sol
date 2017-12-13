pragma solidity ^0.4.18;

import '../math/SafeMath.sol';
import '../lifecycle/Pausable.sol';
import '../token/TicketTokenData.sol';
import '../token/ERC20.sol';

/**
 * @title TicketToken
 * @dev Version of ERC20 Token, representing tickets for an event.
 */

contract TicketToken is Pausable, ERC20 {
    using SafeMath for uint16;

    TicketTokenData public data;

    function TicketToken(address _event, uint16 _cap, uint16 _value, uint8 _type) public Ownable (_event) {
        data = new TicketTokenData(_cap, _value, _type);
    }

    /**
     * @dev Gets the event related to this tickets.
     * @return An address where the event can be found.
     */

    function getEvent() public constant returns (address) {
        return owner;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @return An uint16 representing the amount of the tickets sold.
     */

    function getTotalSupply() public constant returns (uint16) {
        return data.getTotalSupply();
    }

    /**
     * @dev Gets the balance of the specified address.
     * @return An uint16 representing the maximum amount of the tickets.
     */

    function getCap() public constant returns (uint16) {
        return data.getCap();
    }

    /**
     * @dev Gets the balance of the specified address.
     * @return An uint16 representing the value of the tickets
     */

    function getValue() public constant returns (uint16) {
        return data.getValue();
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the balance of.
     * @return An uint256 representing the amount of tickets owned by the passed address.
     */

    function balanceOf(address _owner) public constant returns (uint16 balance) {
        return data.getBalance(_owner);
    }

    function getNumberClients() public constant returns (uint) {
        return data.getNumberClients();
    }

    function getClientAt(uint16 i) public constant returns (address) {
        return data.getClientAt(i);
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */

     function transfer(address _to, uint16 _value) public whenNotPaused returns (bool) {
       require(_to != address(0));
       require(_value <= data.getBalance(msg.sender));
       data.setBalance(msg.sender, data.getBalance(msg.sender).sub(_value));
       if (data.getBalance(msg.sender) < data.getAllowed(msg.sender)) data.setAllowed(msg.sender, data.getBalance(msg.sender));
       data.setBalance(_to, data.getBalance(_to).sub(_value));
       return true;
     }

     /**
      * @dev Transfer tokens from one address to another
      * @param _from address The address which you want to send tokens from
      * @param _to address The address which you want to transfer to
      * @param _value uint256 the amount of tokens to be transferred
      */

     function transferFrom(address _from, address _to, uint16 _value) public onlyOwner whenNotPaused returns (bool success) {
         require(_to != address(0));
         require(_value <= data.getAllowed(_from));
         data.setBalance(_from, data.getBalance(_from).sub(_value));
         data.setAllowed(_from, data.getAllowed(_from).sub(_value));
         data.setBalance(_to, data.getBalance(_to).add(_value));
         return true;
     }

      /**
       * @dev Approve the passed address to resell the specified amount of tokens.
       */

       function approve(uint16 _value) public onlyOwner whenNotPaused returns (bool) {
           require(_value <= data.getBalance(msg.sender));
           if (data.getAllowed(msg.sender) == 0) data.setAllowedIndex(msg.sender);
           data.setAllowed(msg.sender, data.getAllowed(msg.sender) + _value);
           data.setTotalResell(data.getTotalResell() + 1);
           return true;
       }

       /**
        * @dev Function to check the amount of tokens that an owner allowed to resell.
        * @param _owner address The address which owns the funds.
        * @return A uint256 specifying the amount of tokens still available to resell
        */

       function allowance(address _owner) public view returns (uint256) {
           return data.getAllowed(_owner);
       }

      function assignTickets(address _to, uint16 _number) public onlyOwner whenNotPaused {
          require(data.getCap() - data.getTotalSupply() + data.getTotalResell() >= _number);
          while (_number > 0) {
            if((data.getTotalSupply() + 1) <= data.getCap()) {
                data.setBalance(_to, data.getBalance(_to) + 1);
                data.setTotalSupply(data.getTotalSupply() + 1);
                _number -= 1;
            } else {
                for(uint16 i = 0; i < data.getAllowedClusterSize(); i++) {
                    if(data.getAllowed(data.getAllowedIndexAt(i)) > 0) {
                        transferFrom(data.getAllowedIndexAt(i), _to, 1);
                        i -= 1; _number-=1; data.setTotalResell(data.getTotalResell() - 1);
                        if (_number == 0) break;
                    } else {
                        data.deleteAllowedIndexAt(i);
                    }
                }
            }
          }
      }

      /**
       * @dev Function to use a owned ticket.
       */

      function useTicket(uint16 _number) public whenNotPaused {
          require(data.getBalance(msg.sender).sub(_number) > 0);
          data.setBalance(msg.sender, data.getBalance(msg.sender) - 1);
          if (data.getBalance(msg.sender) < data.getAllowed(msg.sender)) data.setAllowed(msg.sender, data.getBalance(msg.sender));
      }

      /**
       * @dev Function to complain via 'Red Button'
       * @param _sender defines the identity complaining.
       * @return uint16 the number of tickets the identity owns.
       */

       function redButton(address _sender) public onlyOwner whenNotPaused returns (uint16) {
           require(data.getBalance(_sender) + data.getUsed(_sender) > 0);
           data.setRedButton(msg.sender, data.getBalance(_sender) + data.getUsed(_sender));
           return data.getRedButton(msg.sender);
       }

}
