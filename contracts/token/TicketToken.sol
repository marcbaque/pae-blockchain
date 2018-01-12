pragma solidity ^0.4.18;

import '../math/SafeMath.sol';
import '../lifecycle/Pausable.sol';
// import '../token/TicketTokenData.sol';
// import '../token/ERC20.sol';

/**
 * @title TicketToken
 * @dev Version of ERC20 Token, representing tickets for an event.
 */

contract TicketToken is Pausable {

    using SafeMath for uint16;
    struct TicketInfo {
        uint8 ticketType;
        uint16 totalAmount;
        uint16 price;
    }

    TicketInfo ticketInfo;

//borrar
    address public thisAddress;

    address[] resellList;
    address[] clients;
    uint16 public ticketsToResell = 0;
    mapping (address => uint16) used;
    mapping (address => bool) pressedRedButton; 
    uint16 redButtonCounter = 0;

    mapping (address => uint16) balances;
    mapping (address => mapping (address => uint16)) public allowed;


    function TicketToken(address _event, uint8 _type, uint16 _amount, uint16 _price) public Pausable(_event) {
        ticketInfo = TicketInfo(_type, _amount, _price);
        balances[this] = _amount;
    }

    function getValue() public constant returns (uint16) {
        return ticketInfo.price;
    }

    function getTotalSupply() public constant returns (uint16) {
        return ticketInfo.totalAmount - balances[this];
    }

    function getRedButtonCounter() public constant returns (uint16) {
        return redButtonCounter;
    }

    function getNumberClients() public constant returns (uint) {
        return clients.length;
    }
    
    function getClientAt(uint16 i) public constant returns (address) {
        return clients[i];
    }

    function balanceOf(address _owner) public constant returns (uint16) {
        return balances[_owner];
    }

    function transfer(address _to, uint16 _value) public returns (bool) {
        thisAddress = msg.sender;
        require(_to != 0x0);
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint16 _value) public returns (bool success) {
        require(_to != 0x0 && _from != 0x0);
        if (balances[_from] >= _value && allowed[_from][_to] >= _value) {
            balances[_to] = balances[_to].sub(_value);
            balances[_from] = balances[_from].add(_value);
            allowed[_from][_to] = allowed[_from][_to].sub(_value);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _from, address _spender, uint16 _value) public returns (bool) {
        if (balances[_spender] >= _value) {
            allowed[_from][_spender] = _value;
            return true;
        } else {
            return false;
        }
    }

    function resell(uint16 _amount) returns (bool){
        if (balances[msg.sender] - allowed[msg.sender][this] >= _amount) {
            bool found = false;
            uint position= 0;
            (found, position) = containsElement(resellList, msg.sender);

            if (!found) {
                resellList.push(msg.sender);
            }    
            allowed[msg.sender][this].add(_amount);
            ticketsToResell.add(_amount);
            assert(ticketsToResell + balances[this] >= ticketInfo.totalAmount);
            return true;
        } else {
            return false;
        }
    }

    function assignTickets(address _to, uint16 _amount) public returns (bool) {
    
        if(balances[this] + ticketsToResell > _amount) {
            if (balances[this] > 0) {
                if (balances[this] >= _amount) {
                    this.transfer(_to, _amount);
                    addClient(_to);
                    return true;
                } else {
                    uint16 sold = balances[this];
                    transfer(_to, sold);
                    _amount = _amount.sub(sold);
                    
                }
            } 
            address clientReselling;
            for (uint16 i; i < resellList.length && _amount > 0; i++) {
                clientReselling = resellList[i];
                if(allowed[clientReselling][this] >= _amount) {
                    transferFrom(clientReselling, this, _amount);
                    transfer(_to, _amount);
                    ticketsToResell = ticketsToResell.sub(_amount);
                    _amount = _amount.sub(_amount);
                    //TicketsResold(_resellList[i], _amount);
                    addClient(_to);
                    return true;
                } else if (allowed[clientReselling][this] > 0) {
                    uint16 resold = allowed[clientReselling][this];
                    transferFrom(clientReselling, this, resold);
                    transfer(_to, resold);
                    _amount = _amount.sub(resold);
                    ticketsToResell = ticketsToResell.sub(resold);
                    //TicketsResold(_resellList[i], resold);
                }
            }
            return false;
        }
        
    }

    function useTicket(uint16 _amount) public returns (bool) {
        if (balances[msg.sender] >= _amount) {
            balances[msg.sender] = balances[msg.sender].sub(_amount);
            used[msg.sender] = used[msg.sender].add(_amount);
            return true;
        } else {
            return false;
        }
    }

    function redButton(address _from) public returns (uint16) {
        if (pressedRedButton[_from]) return 0;
        pressedRedButton[_from] = true;
        return used[_from];
        
    }

    function addClient(address _client) {
        bool found = false;
        uint position= 0;  
        (found, position) = containsElement(resellList, _client);
        if(!found) clients.push(_client);
    }

    function containsElement(address[] array, address element) internal returns (bool found, uint position) {
        for (uint i = 0; i < array.length && !found; ++i) {
            if (array[i] == element) return (true,i);
        }
        return (false, 0);
    }
}