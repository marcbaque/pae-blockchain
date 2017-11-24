import "./BasicUser.sol";
import "./Organizer.sol";
import "./Ownable.sol";

contract UserFactory is Ownable {
    
    mapping(bytes32 => address) public idMapUser;

    
    event basicUserCreated(address buAddress, address owner);
    event organizerCreated(address organizerAddress, address owner);

    function UserFactory() Ownable(msg.sender) {
        
    }
    
    function createBasicUser(address owner, bytes32 id) {
        BasicUser bu = new BasicUser(owner, id);
        idMapUser[id] = bu;

        basicUserCreated(bu, owner);
    }
    
    function createOrganizer(bytes32 id) {
        Organizer org = new Organizer(msg.sender, id);
        idMapUser[id] = org;

        organizerCreated(org, msg.sender);
    }
    
}