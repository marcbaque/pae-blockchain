import "./User.sol";
import "./Event.sol";
import "./EventFactory.sol";
import "./EventContract.sol";

pragma solidity ^0.4.15;

contract Organization is User {
    
    EventFactory eventFactory; //So the Organization can create Events
    Event[] public events; // Participating In
    bool verified;
    
    
    function Organization (address _owner, uint _id, string _name, string _phone, string _email, EventFactory _eventFactory) User(_owner, _id, _name, _phone, _email) {
        verified = false;
        eventFactory = _eventFactory;
    }
    
    modifier onlyEventFactory() {
        require(EventFactory(msg.sender) == eventFactory);
        _;
    }

    function addEvent(Event newEvent) onlyEventFactory {
        events.push(newEvent);
    }

    function createEvent(string name, string description) {
        Event newEvent = eventFactory.createEvent(name, description);
        events.push(newEvent);
    }

    function addOrganizerToEvent(address eventAddress, address newOrganizer) onlyOwner returns (bool){
        Event e = Event(eventAddress);
        require(msg.sender == e.getOwner());
        EventContract eventContract = new EventContract(e, msg.sender, newOrganizer, 50, 50,"Condiciones: Hacerlo muy bien!");
        
        return e.addContractWith(eventContract, newOrganizer);
    }
    
    //Change Events Status
    function getContractsAsOwnerFromEvent(address eventAddress) onlyOwner returns (address[]) {
        Event e = Event(eventAddress);
        address[] eventContracts;
        for(uint i=0; i < e.getNumberOfContracts(); i++) {
            eventContracts[i] = e.getContractByPosition(i);
        }
        return eventContracts;
    }
    
    
    
    function getContractAsContractorFromEvent(address eventAddress) onlyOwner returns (address) {
        Event e = Event(eventAddress);
        address eventContract = e.getMyContract();
        return eventContract;
    }
    function accept(address eventContractAddress) onlyOwner {
        EventContract eventContract = EventContract(eventContractAddress);
        eventContract.accept();

    }
    


}