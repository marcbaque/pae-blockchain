pragma solidity ^0.4.18;

import "./Ownable.sol";
import "./Event.sol";
import "./TicketToken.sol";

contract EventFactory is Ownable {
    
    address[] events;

    event eventCreated(address eventAddress, address owner);
    
    function EventFactory() Ownable(msg.sender) {        
    }
    
    
    function createEvent() returns (address) {
                            
        //TODO: Add modifier onlyOrganizers() -> need to have UserFactory?

        Event newEvent = new Event(msg.sender, events.length);
        events.push(newEvent);
        eventCreated(newEvent, msg.sender);
        return newEvent;


    }
    
}