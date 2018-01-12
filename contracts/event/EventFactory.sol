pragma solidity ^0.4.18;

import "./Event.sol";

contract EventFactory is Ownable {

  address internal ticketTokenFactory;
  address internal bsTokenFrontend;
  address[] public events;

  event EventCreated(address owner, address eventAddress);

  /**
   * @dev Creates the factory, it must be created just once by the admin of the system.
   */

  function EventFactory (address _ticketTokenFactory, address _bsTokenFrontend) public Ownable(msg.sender) {
      ticketTokenFactory = _ticketTokenFactory;
      bsTokenFrontend = _bsTokenFrontend;
  }

  /**
   * @dev Creates and instantiates a Event.
   * @param _id is the id of the event.
   */

  function createEvent(uint _id) public returns (address) {
      address _event = new Event(msg.sender, bsTokenFrontend, ticketTokenFactory, _id);
      events.push(_event);
      EventCreated(msg.sender, _event);
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
