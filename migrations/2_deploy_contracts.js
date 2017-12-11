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


module.exports = function(deployer) {

  deployer.deploy(Event);

  deployer.deploy(Admin);
  deployer.deploy(Auth);
  deployer.deploy(AuthStoppable);
  deployer.deploy(BSToken);
  deployer.deploy(BSTokenBanking);
  deployer.deploy(BSTokenData);
  deployer.deploy(BSTokenFrontend);
  deployer.deploy(PermissionManager);
  deployer.deploy(Stoppable);
  deployer.deploy(Token);
  deployer.deploy(TokenRecipient);
  
  deployer.deploy(EventData);
  deployer.deploy(EventFactory);
  deployer.deploy(UserFactory);
  deployer.deploy(Pausable);
  deployer.deploy(SafeMath);
  deployer.deploy(MultiOwnable);
  deployer.deploy(Ownable);
  deployer.deploy(ERC20);
  deployer.deploy(TicketToken);
  deployer.deploy(TicketTokenData);
  deployer.deploy(BasicUser);
  deployer.deploy(Organizer);
  deployer.deploy(User);
 
  deployer.link(Admin, PermissionManager);
  deployer.link(Auth, PermissionManager);
  deployer.link(AuthStoppable, Auth);
  deployer.link(BSToken, BSTokenData);
  deployer.link(BSTokenBanking, Admin);
  deployer.link(BSTokenBanking, BSTokenData);
  deployer.link(BSTokenData, Stoppable);
  deployer.link(BSTokenFrontend, BSToken);
  deployer.link(BSTokenFrontend, Token);
  deployer.link(BSTokenFrontend, BSTokenData);
  deployer.link(BSTokenFrontend, TokenRecipient);
  deployer.link(BSTokenFrontend, AuthStoppable);
  deployer.link(Stoppable, Admin);
  deployer.link(Event, Ownable);
  deployer.link(Event, TicketToken);
  deployer.link(Event, EventData);
  deployer.link(EventData, Ownable);
  deployer.link(EventData, TicketToken);
  deployer.link(EventFactory, Ownable);
  deployer.link(EventFactory, Event);
  deployer.link(EventFactory, EventData);
  deployer.link(UserFactory, BasicUser);
  deployer.link(UserFactory, Organizer);
  deployer.link(UserFactory, Ownable);
  deployer.link(Pausable, MultiOwnable);
  deployer.link(TicketToken, SafeMath);
  deployer.link(TicketToken, Pausable);
  deployer.link(TicketToken, TicketTokenData);
  deployer.link(TicketTokenData, Ownable);
  deployer.link(BasicUser, User);
  deployer.link(BasicUser, Event);
  deployer.link(BasicUser, TicketToken);
  deployer.link(Organizer, User);
  deployer.link(Organizer, Event);
  deployer.link(Organizer, EventFactory);
  deployer.link(User, Ownable);
};
