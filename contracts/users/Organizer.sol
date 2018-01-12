pragma solidity ^0.4.0;

import "./User.sol";
import "./../token/TicketToken.sol";
import "./../event/Event.sol";
import "./../event/EventFactory.sol";
import "./../bs-token/BSTokenFrontend.sol";

contract Organizer is User {

    address[] public events;
    address eventFactory;

    function Organizer(address _owner, address _BSTokenFrontend, address _eventFactory) User (_BSTokenFrontend, _owner) {
      eventFactory = _eventFactory;
    }

    function createEvent(uint _id) public onlyOwner {
        events.push(EventFactory(eventFactory).createEvent(_id));
    }

    // function setDate(address _event, uint _date, uint _duration) public onlyOwner {
    //     Event(_event).initializeDate(_date, _duration);
    // }

    function addOrganizer(address _event, address _organizer, uint16 _percentage) public onlyOwner {
        Event(_event).addOrganizer(_organizer, _percentage);
    }

    function addTicket(address _event, uint8 _ticketType, uint16 _price, uint16 _quantity) public onlyOwner {
        Event(_event).addTicket(_ticketType, _price, _quantity);
    }

    function acceptEvent(address _event) public onlyOwner {
        Event(_event).accept();
    }

    function openEvent(address _event) public onlyOwner {
        Event(_event).open();
    }

    function startEvent(address _event) public onlyOwner {
        Event(_event).start();
    }

    function endEvent(address _event) public onlyOwner {
        Event(_event).end();
    }

    function cancelEvent(address _event) public onlyOwner {
        Event(_event).cancel();
    }

    function evaluate(address _event, bool success) public onlyOwner {
        Event(_event).evaluate(success);
    }

    // Has to be called when payment ready
    function getPayment(address _event) public onlyOwner {
        BSTokenFrontend(_BSTokenFrontend).transferFrom(_event, address(this), BSTokenFrontend(_BSTokenFrontend).allowance(_event, address(this)));
    }

}
