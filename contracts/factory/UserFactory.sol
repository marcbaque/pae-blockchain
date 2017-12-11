import "./../user/BasicUser.sol";
import "./../user/Organizer.sol";
import "./../ownership/Ownable.sol";

contract UserFactory is Ownable {
    
    mapping(bytes32 => address) public idMapUser;

    
    event BasicUserCreated(address buAddress, address owner);
    event OrganizerCreated(address organizerAddress, address owner);

    function UserFactory() Ownable(msg.sender) {
        
    }
    
    function createBasicUser(address owner, bytes32 id) {
        BasicUser bu = new BasicUser(owner, id);
        idMapUser[id] = bu;

        BasicUserCreated(bu, owner);
    }
    
    function createOrganizer(bytes32 id) {
        Organizer org = new Organizer(msg.sender, id);
        idMapUser[id] = org;

        OrganizerCreated(org, msg.sender);
    }
    
}