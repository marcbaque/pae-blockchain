var EventFactory = artifacts.require("./EventFactory.sol");
var UserFactory = artifacts.require("./UserFactory.sol");
var Artist = artifacts.require("./Artist.sol");
var Organization = artifacts.require("./Organization.sol");
var User = artifacts.require("./User.sol");
var Event = artifacts.require("./Event.sol");
var EventContract = artifacts.require("./EventContract.sol");

module.exports = function(deployer) {
  deployer.deploy(UserFactory);
  deployer.deploy(EventFactory);
  deployer.deploy(Organization);
  deployer.deploy(Artist);
  deployer.deploy(EventContract);
  deployer.link(UserFactory, EventFactory);
  deployer.link(UserFactory, Artist);
  deployer.link(EventFactory, Artist);
  deployer.link(Organization, Artist);
  deployer.link(Organization, UserFactory);
  deployer.link(Organization, EventFactory);

};
