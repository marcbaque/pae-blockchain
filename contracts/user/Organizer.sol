import "./User.sol";
import "./../event/Event.sol";
import "./../factory/EventFactory.sol";

contract Organizer is User {
    
    address[] public events;

    EventFactory eventFactory;
    
    event EventCreated(address newEvent, uint position);
    
    function Organizer(address _owner, bytes32 _id) User(_owner, _id) {
        
    }
    
    function setEventFactory(address eventFactoryAddress) {
        eventFactory = EventFactory(eventFactoryAddress);
    } 
    
    function createEvent() {

        address newEvent = eventFactory.createEvent();
        events.push(newEvent);
    }
    
    function initializeDate(address eventAddress, uint _date, uint _duration) public onlyOwner {
        Event e = Event(eventAddress);
        e.initializeDate(_date, _duration);
    }

    function addOrganizer(address eventAddress, address _organizerAddress, uint16 _percentage) public onlyOwner {
        Event e = Event(eventAddress);
        e.addOrganizer(_organizerAddress, _percentage);
    }

    
    function addTicket(address eventAddress, uint8 _ticketType, uint16 _price, uint16 _quantity) public onlyOwner {
       Event e = Event(eventAddress);
       e.addTicket(_ticketType, _price, _quantity);
    }

    function acceptEvent(address eventAddress) onlyOwner {
        Event e = Event(eventAddress);
        e.accept();
    }

    function cancelEvent(address eventAddress) onlyOwner {
        Event e = Event(eventAddress);
        e.cancel();
    }

    function evaluateEvent(address eventAddress, bool result) {
        Event e = Event(eventAddress);
        e.evaluate(result);
    }

    function askPayment(address eventAddress) onlyOwner {
        //
    }
}