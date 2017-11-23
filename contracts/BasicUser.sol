import "./User.sol";

contract BasicUser is User {
    
    address[] tickets;
    
    function BasicUser(address _owner, bytes32 _id) User (_owner, _id) {
        
    }
    
    function getTickets() constant returns (address[]) {
        return tickets;
    }
    
    function buyTicket(address eventAddress, string cc) onlyOwner public {
        //Event e = Event(eventAddress);
        //e.buyTicket(cc);
    }
    
    function resellTicket(address ticketAddress) onlyOwner public {
        //TicketToken t = TicketToken(ticketAddress);
        //t.resell();
    }
    
    function redButton(address ticketAddress) {
        //TicketToken t = TicketToken(ticketAddress);
        //t.redButton();
    }
    
    
    
}