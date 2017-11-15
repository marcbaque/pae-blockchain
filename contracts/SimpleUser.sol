pragma solidity ^0.4.15;

contract SimpleUser {
    
    address owner;
    uint public id;
    string name;
    string surnames;
    uint age;
    
    function SimpleUser(address _owner, uint _id, string _name, string _surnames, uint _age) {
        owner = _owner;
        id = _id;
        name = _name;
        surnames = _surnames;
        age = _age;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function getName() constant returns (string) {
        return name;
    }
    
    function setName(string _name) {
        name = _name;
    }
}