import "./../ownership/Ownable.sol";

contract User is Ownable {
    
    bytes32 id;
    
    
    function User(address _owner, bytes32 _id) Ownable(_owner) {
        owner = _owner;
        id = _id;
    }
    
    function getId() constant returns (bytes32) {
        return id;
    }
    
    
    
}