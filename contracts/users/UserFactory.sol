pragma solidity ^0.4.18;

import "./BasicUser.sol";
import "./Organizer.sol";

contract UserFactory is Ownable {

  address bsToken;
  address eventFactory;

  address[] basicUsers;
  address[] organizers;

  mapping(address => bool) usedAddresses;

  function UserFactory(address _BSTokenFrontend, address _EventFactory) public {
    bsToken = _BSTokenFrontend;
    eventFactory = _EventFactory;
  }

  function createBasicUser() public returns (address){
    require(!usedAddresses[msg.sender]);
    address basicUser = new BasicUser(msg.sender, bsToken);
    basicUsers.push(basicUser);
    usedAddresses[msg.sender] = true;
    return basicUser;
  }

  function createOrganizer() public returns (address){
    require(!usedAddresses[msg.sender]);
    address organizer = new Organizer(msg.sender, bsToken, eventFactory);
    organizers.push(organizer);
    usedAddresses[msg.sender] = true;
    return organizer;
  }

}
