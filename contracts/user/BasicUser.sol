import "./User.sol";
import "./../event/Event.sol";
import "./../token/TicketToken.sol";

contract BasicUser is User {
    
    address[] tickets;
    
    function BasicUser(address _owner, bytes32 _id) User (_owner, _id) {
        
    }
    
    function getTickets() constant returns (address[]) {
        return tickets;
    }
    
    function buyTicket(address eventAddress, uint8 ticketType, uint8 amount) onlyOwner public {
        Event e = Event(eventAddress);
        e.buyTickets(ticketType, amount);
    }
    
    function resellTicket(address ticketAddress, uint16 value) onlyOwner public {
        TicketToken t = TicketToken(ticketAddress);
        t.approve(value);
        
    }
    
    function redButton(address eventAddress) {
        Event e = Event(eventAddress);
        e.redButton();
    }

    function askRefund(address ticketAddress) {
        
    }
}