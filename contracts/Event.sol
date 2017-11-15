pragma solidity ^0.4.15;

import "./EventContract.sol";


contract Event {
    
    address owner; 
    uint public id;
    string public name;
    string public description;

    address[] public organizers;
    EventStatus public eventStatus;

    mapping(address => EventContract) userMapContract;
    mapping(address => bool) contractMapRegistered;
    address[] contracts;
    
    
    
    function Event(address _owner, uint _id, string _name, string _description) {
        owner = _owner; //owner = User
        organizers.push(owner);
        name = _name;
        description = _description;
    }
    
    // Enums
    
    enum EventStatus {Pending, Accepted, OnGoing, Finished}
    
    
    //Modifiers
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyInStatus(EventStatus requiredStatus) {
        require(eventStatus == requiredStatus);
        _;
    }
    modifier onlyOrganizers() {
        for(uint i = 0; i < organizers.length; i++) {
            if(organizers[i] == msg.sender) {
                _;
            }
        }
        revert();
    }
    modifier onlyInPending() {
        require(eventStatus == EventStatus.Pending);
        _;
    }
    modifier onlyInAccepted() {
        require(eventStatus == EventStatus.Accepted);
        _;
    }
    modifier onlyInOnGoing() {
        require(eventStatus == EventStatus.OnGoing);
        _;
    }
    
    //Events
    
    event StatusChanged(EventStatus newEventStatus);    
    
    
    //Functions
    
    
    function addContractWith(address eventContractAddress, address newOrganizer) onlyOwner returns (bool) {
        organizers.push(newOrganizer);
        EventContract eventContract = EventContract(eventContractAddress);
        userMapContract[newOrganizer] = eventContract;
        contractMapRegistered[eventContract] = true;
        contracts.push(eventContract);
        return true;
    }

    function getOwner() constant onlyOrganizers returns (address) {
        return owner;
    }
    
    function getNumberOfContracts() constant onlyOwner returns (uint)  {
        return contracts.length;
    }
    function getContractByPosition(uint pos) constant returns (address) {
        return contracts[pos];
    }
    function getAllContracts() onlyOwner returns (address[]) {
        return contracts;
    }
    function getContractByContractor(address contractor) onlyOwner returns (EventContract) {
        return userMapContract[contractor];
    }
    function getMyContract() constant onlyOrganizers returns(EventContract) {
        return userMapContract[msg.sender];
    }
    function changeEventStatus(EventStatus newEventStatus) internal {
        eventStatus = newEventStatus;
        //StatusChanged(eventStatus);
    }

    //Ahora mismo hacemos esto porque suponemos solo un contrato. Cuando haya mas habra
    //que hacer un mapping de estados por contrato y esta funcion cambiara el estado del contrato
    //en concreto. Se mirara si todos los contratos tienen lo mismo y hacia adelante.

    function updateEventStatusFromContract(address eventContractAddress) onlyOrganizers {
        EventContract eventContract = EventContract(eventContractAddress);
        EventContract.ContractStatus conStatus =  eventContract.getContractStatus();

        if(conStatus == EventContract.ContractStatus.Accepted) {
            changeEventStatus(EventStatus.Accepted);
        }


    }


    
}
