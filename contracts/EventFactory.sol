import "./Ownable.sol";
import "./Event.sol";
import "./TicketToken.sol";

contract EventFactory is Ownable {
    
    address[] events;
    
    function EventFactory() Ownable(msg.sender) {
        
    }
    
    
    function createEvent(address[] organizers, uint[] percentage, string date, string duration, uint capacity, uint ticketPrice) returns (address) {
                            
        //Add parameters: fecha, lista de organizadores 
        //Todo: Add modifier onlyOrganizers() -> need to have UserFactory?
        TicketToken ticket = new TicketToken(capacity, ticketPrice, "Regular");
        Event newEvent = new Event(msg.sender, events.length, organizers, percentage, date, duration, ticket);
        events.push(newEvent);
        return newEvent;
    }
    
}