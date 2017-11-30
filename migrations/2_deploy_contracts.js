var EventFactory = artifacts.require("./EventFactory.sol");
var UserFactory = artifacts.require("./UserFactory.sol");
var BasicUser = artifacts.require("./BasicUser.sol");
var Organizer = artifacts.require("./Organizer.sol");
var User = artifacts.require("./User.sol");
var Event = artifacts.require("./Event.sol");
var TicketToken = artifacts.require("./TicketToken.sol");
var Ownable = artifacts.require("./Ownable.sol");

module.exports = function(deployer) {
  deployer.deploy(EventFactory);
  deployer.deploy(UserFactory);
  deployer.deploy(User);
  deployer.deploy(BasicUser);
  deployer.deploy(Organizer);
  deployer.deploy(TicketToken);
  deployer.deploy(Event);
  deployer.deploy(Ownable);
  deployer.link(UserFactory, EventFactory);
  deployer.link(UserFactory, BasicUser);
  deployer.link(EventFactory, BasicUser);
  deployer.link(Organizer, BasicUser);
  deployer.link(Organizer, UserFactory);
  deployer.link(Organizer, EventFactory);
  deployer.link(BasicUser, Event);
  deployer.link(Organizer, Event);

};
