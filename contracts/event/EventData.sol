pragma solidity ^0.4.15;

import "./../ownership/Ownable.sol";
import "./../token/TicketToken.sol";

contract EventData {

    /* Only logic contracts can interactuate with the token data */
    mapping(address => bool) logics;

    enum EventStatus {Pending, Accepted, Opened, OnGoing, Finished, Success, Failed, Frozen, Cancelled}
    enum OrganizerStatus {Pending, Accepted, Success, Failed}

    /* Event Information */
    uint public id;             /* id: identifier of the event (Theorically physical db related) */
    uint public date;           /* date: celebration date of the event */
    uint public duration;       /* duration: duration of the given event */
    EventStatus public eventStatus;

    /* Organizers Information */
    address[] organizers;
    mapping (address => OrganizerInfo) public organizersInfo;

    struct OrganizerInfo {
        OrganizerStatus status;
        uint16 percentage;              /* percentage: percentage of earnings he is given */
    }

    /* Tickets */
    address[] tickets;              /* tickets: collection of all the tickets for a concert */

    uint16 redButton = 0;
    uint totalTickets = 0;

    modifier onlyLogic () {
        require(logics[msg.sender]);
        _;
    }

    function EventData (uint _id) {
        id = _id;
        logics[msg.sender] = true;
    }

    function addLogics(address _event) onlyLogic {
        logics[_event] = true;
    }

    function selfDestructLogic() onlyLogic {
        logics[msg.sender] = false;
    }

    function getId() constant returns (uint) {
        return id;
    }

    function getDate() constant returns (uint) {
        return date;
    }

    function setDate(uint _date) onlyLogic {
        date = _date;
    }

    function getDuration() constant returns (uint) {
       return duration;
    }

    function setDuration(uint _duration) onlyLogic {
       duration = _duration;
    }

    function getEventStatus() returns (uint8) {
        return uint8(eventStatus);
    }

    function setEventStatus(uint8 _eventStatus) onlyLogic {
        eventStatus = EventStatus(_eventStatus);
    }

    function getNumberOrganizers() constant returns (uint) {
        return organizers.length;
    }

    function getOrganizerAt(uint i) constant returns (address) {
        return (organizers[i]);
    }

    function getOrganizerInfo(address _organizer) constant returns (uint, uint16) {
        return (uint(organizersInfo[_organizer].status), organizersInfo[_organizer].percentage);
    }

    function addOrganizer(address _organizer, uint16 _percentage) {
        organizers.push(_organizer);
        organizersInfo[_organizer] = OrganizerInfo(OrganizerStatus(0), _percentage);
    }

    function setOrganizerInfo(address _organizer, uint8 _status, uint16 _percentage) {
        organizersInfo[_organizer] = OrganizerInfo(OrganizerStatus(_status), _percentage);
    }

    function getNumberTickets() constant returns (uint) {
        return tickets.length;
    }

    function getTicketAt(uint i) constant returns (address) {
        return tickets[i];
    }

    function addTicket(address _ticket) {
        tickets.push(_ticket);
        totalTickets += TicketToken(_ticket).getTotalSupply();
    }

    function getTotalTickets() constant returns (uint) {
        return totalTickets;
    }

    function redButtonPressed(uint16 _value) {
        redButton += _value;
    }

    function getRedButtonCount() constant returns (uint16) {
        return redButton;
    }


}