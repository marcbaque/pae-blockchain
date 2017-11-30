import "./User.sol";
import "./EventFactory.sol";

contract Organizer is User {
    
    mapping(uint => address) public events;
    uint[] public eventIds; // https://ethereum.stackexchange.com/questions/15337/can-we-get-all-elements-stored-in-a-mapping-in-the-contract
    uint eventsSize;

    EventFactory eventFactory;
    
    event EventCreated(address newEvent, uint position);
    
    function Organizer(address _owner, bytes32 _id) User(_owner, _id) {
        
    }
    
    function setEventFactory(address eventFactoryAddress) {
        eventFactory = EventFactory(eventFactoryAddress);
    } 
    
    function createEvent(address[] organizers, uint[] percentage,
                        string date, string duration, uint capacity, uint ticketPrice) {

        address newEvent = eventFactory.createEvent(organizers, percentage, date, duration, capacity, ticketPrice);
        events[eventsSize] = newEvent;
        eventIds.push(eventsSize);
        eventsSize = eventsSize + 1;
        EventCreated(newEvent, events.length-1);
    }
    
    function acceptEvent(address eventAddress) onlyOwner {
        Event e = Event(eventAddress);
        e.accept();
    }

    function cancelEvent(address eventAddress) onlyOwner {
        Event e = Event(eventAddress);
        e.cancel();
    }

    function setResult(result) {
        // Que era esto?
    }

    function askPayment(address eventAddress) onlyOwner {
        Event e = Event(eventAddress);
        e.askPayment();
    }
}