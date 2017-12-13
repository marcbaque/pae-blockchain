pragma solidity ^0.4.18;

import "./Event.sol";

contract EventFactory is Ownable {

  address internal ticketTokenFactory;
  address internal bsTokenFrontend;
  address[] public events;

  /**
   * @dev Creates the factory, it must be created just once by the admin of the system.
   */

  function EventFactory (address _ticketTokenFactory, address _bsTokenFrontend) public Ownable(msg.sender) {
      ticketTokenFactory = _ticketTokenFactory;
      bsTokenFrontend = _bsTokenFrontend;
  }

  /**
   * @dev Creates and instantiates a Event.
   * @param _organizer is the first organizer of the event (the one creating it).
   * @param _percentage is the percentage the organizer expect to receive.
   * @param _id is the id of the event.
   */

  function createEvent(address _organizer, uint16 _percentage, uint _id) public returns (address) {
      address _event = new Event(owner, ticketTokenFactory, bsTokenFrontend, _organizer, _percentage, _id);
      events.push(_event);
      return _event;
  }

  /**
   * @dev Gets the amount of events previously created.
   */

  function getNumberEvents() public constant returns(uint) {
      return events.length;
  }

  /**
   * @dev Gets the event created i, ordered by creation.
   * @param i is the position of creation selected.
   */

  function getEventAt(uint i) public constant returns(address) {
      return events[i];
  }

}
