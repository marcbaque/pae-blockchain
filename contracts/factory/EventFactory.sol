pragma solidity ^0.4.18;

import "./../ownership/Ownable.sol";
import "./../event/Event.sol";
import "./../event/EventData.sol";

contract EventFactory is Ownable {
    
    address[] events;

    event EventCreated(address eventAddress, address owner);
    
    function EventFactory() Ownable(msg.sender) {        
    }
    
    
    function createEvent() returns (address) {
                            
        //TODO: Add modifier onlyOrganizers() -> need to have UserFactory?
        EventData eventData = new EventData(events.length);
        Event newEvent = new Event(owner, msg.sender, eventData);
        events.push(newEvent);
        EventCreated(newEvent, msg.sender);
        return newEvent;


    }
    
}