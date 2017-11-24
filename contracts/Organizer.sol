import "./User.sol";
import "./EventFactory.sol";

contract Organizer is User {
    
    address[] events;
    EventFactory eventFactory;
    
    event EventCreated(address newEvent, uint position);
    
    function Organizer(address _owner, bytes32 _id) User(_owner, _id) {
        
    }
    
    function setEventFactory(address eventFactoryAddress) {
        eventFactory = EventFactory(eventFactoryAddress);
    } 
    
    function createEvent(address[] organizers, uint[] percentage, string date, 
                        string duration, uint capacity, uint ticketPrice) {
        address newEvent = eventFactory.createEvent(organizers, percentage, date, duration, capacity, ticketPrice);
        events.push(newEvent);
        EventCreated(newEvent, events.length-1);
    }
    
    function getEvent(uint pos) onlyOwner constant returns(address) {
        return events[pos];
    }

    
    function accept(address eventAddress) onlyOwner {
        Event e = Event(eventAddress);
        e.accept();
    }
    
    
    function success(address eventAddress, bool eventSuccess) onlyOwner {
        Event e = Event(eventAddress);
        e.success(eventSuccess);
    }
    

    
    function askPayment(address eventAddress) onlyOwner {
        Event e = Event(eventAddress);
        e.askPayment();
    }
    
    
    
}