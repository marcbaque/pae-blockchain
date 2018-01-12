var Admin = artifacts.require("./bs-token/Admin.sol");
var Auth = artifacts.require("./bs-token/Auth.sol");
var AuthStoppable = artifacts.require("./bs-token/AuthStoppable.sol");
var BSToken = artifacts.require("./bs-token/BSToken.sol");
var BSTokenBanking = artifacts.require("./bs-token/BSTokenBanking.sol");
var BSTokenData = artifacts.require("./bs-token/BSTokenData.sol");
var BSTokenFrontend = artifacts.require("./bs-token/BSTokenFrontend.sol");
var PermissionManager = artifacts.require("./bs-token/PermissionManager.sol");
var Stoppable = artifacts.require("./bs-token/Stoppable.sol");
var Token = artifacts.require("./bs-token/Token.sol");
var TokenRecipient = artifacts.require("./bs-token/TokenRecipient.sol");

var Event = artifacts.require("./event/Event.sol");
var EventData = artifacts.require("./event/EventData.sol");

var EventFactory = artifacts.require("./factory/EventFactory.sol");
var UserFactory = artifacts.require("./factory/UserFactory.sol");

var Pausable = artifacts.require("./lifecycle/Pausable.sol");

var SafeMath = artifacts.require("./math/SafeMath.sol");

var MultiOwnable = artifacts.require("./ownership/MultiOwnable.sol");
var Ownable = artifacts.require("./ownership/Ownable.sol");

var ERC20 = artifacts.require("./token/ERC20.sol");
var TicketToken = artifacts.require("./token/TicketToken.sol");
var TicketTokenData = artifacts.require("./token/TicketTokenData.sol");

var BasicUser = artifacts.require("./user/BasicUser.sol");
var Organizer = artifacts.require("./user/Organizer.sol");
var User = artifacts.require("./user/User.sol");
var TicketTokenFactory = artifacts.require("./token/TicketTokenFactory.sol");

module.exports = async function(deployer, network, accounts) {
  
  await deployer.deploy(PermissionManager, {from: accounts[0]});
  await deployer.deploy(BSTokenData, {from: accounts[0]});
  await deployer.deploy(BSTokenFrontend, accounts[0], PermissionManager.address);
  await deployer.deploy(BSToken, BSTokenData.address, BSTokenFrontend.address, {from: accounts[0]});
  
  await deployer.deploy(TicketTokenFactory, {from: accounts[0]});
  await deployer.deploy(EventFactory, TicketTokenFactory.address, BSTokenFrontend.address, {from: accounts[0]});
  await deployer.deploy(UserFactory, BSTokenFrontend.address, EventFactory.address, {from: accounts[0]}); 

    
};
