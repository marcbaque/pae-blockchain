pragma solidity ^0.4.15;

import "./SimpleUser.sol";

contract SimpleUserFactory {
    mapping(address => address) usersMap;
    SimpleUser[] usersList;
    
    
    modifier isNotRegistered() {
        require(usersMap[msg.sender] == 0);
        _;
    }
    
    function createSimpleUser(string _name, string _surnames, uint _age) 
             isNotRegistered 
    {
        SimpleUser user = new SimpleUser(msg.sender,usersList.length, _name, _surnames, _age);
        usersList.push(user);
        usersMap[msg.sender] = user;
        
    }

    function getUserByOwner() constant returns (address){
        return usersMap[msg.sender];
    } 
    
    function getUserById(uint id) constant returns (SimpleUser) {
        return usersList[id];
    }
    
    
}

