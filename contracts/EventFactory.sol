pragma solidity ^0.4.15;

import "./Event.sol";
import "./UserFactory.sol";
import "./Organization.sol";

contract EventFactory {
    
    address owner;
    address[] admins;
    UserFactory public userFactory;
    
    Event[] public eventList;
    mapping(address => Event[]) usersMapEvents;
    
    function EventFactory() {
        owner = msg.sender;
        admins.push(owner);
    }
    
    function initializeUserFactory(address userFactoryAddress) onlyOwner {
        UserFactory uf = UserFactory(userFactoryAddress);
        userFactory = uf;
    }
    //MOdifiers
    modifier onlyOrganization() {
        require(userFactory.isOrganization(msg.sender));
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    //Functions
    
    function createEvent(string name, string description) onlyOrganization returns (Event) {
        //Nota: msg.sender = User
        Event newEvent = new Event(msg.sender, eventList.length, name, description);
        usersMapEvents[msg.sender].push(newEvent); //Esto debería poder hacerse
        eventList.push(newEvent);
        return newEvent;
        //Organization org = Organization(msg.sender);
        //org.addEvent(e);
    }   

    function getMyEvents() onlyOrganization constant returns (Event[]) {
        //Nota: msg.sender = User
        return usersMapEvents[msg.sender];
    }
}