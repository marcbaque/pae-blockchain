pragma solidity ^0.4.15;

contract TicketToken {

    uint public quantity;
    uint public available;
    uint public value;
    string public ticket_type;

    mapping(address => uint) userTicketMap;

    function TicketToken (uint _quantity, uint _value, string _ticket_type) {

        quantity = _quantity;
        available = _quantity;
        value = _value;
        ticket_type = _ticket_type;

    }

    function numberTicketsUser (address _user) constant returns (uint) { return userTicketMap[_user];  }

    function assignTickets(address _to, uint _number) {

        if (available - _number > 0) { userTicketMap[_to] += _number;  available -= _number; }
        else { revert; }

    }

    function transferTickets(address _from, address _to, uint _number) {

        if (userTicketMap[_from] >= _number) { userTicketMap[_from] -= _number; userTicketMap[_to] += _number; }
        else { revert; }

    }

    function useTicket(address _from) {

        userTicketMap[_from] -= 1;

    }

}