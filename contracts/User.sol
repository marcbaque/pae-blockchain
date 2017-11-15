pragma solidity ^0.4.15;

contract User {
    
    address owner;
    uint public id;
    string public name;
    string phone;
    string email;

    
    function User(address _owner, uint _id, string _name, string _phone, string _email) {
        owner = _owner;
        id = _id;
        name = _name;
        phone = _phone;
        email = _email;
    }
    
    //Modifiers
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    //Functions
    
    function changeEmail(string newEmail) onlyOwner {
        email = newEmail;
    }
    
}