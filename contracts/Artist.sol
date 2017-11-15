pragma solidity ^0.4.15;

import "./User.sol";
import "./Organization.sol";
import "./EventFactory.sol";
//Welcome

contract Artist is Organization {
    
    
    function Artist (address _owner, uint _id, string _name, string _phone, string _email, EventFactory _eventFactory) 
    Organization(_owner, _id, _name, _phone, _email, _eventFactory) {

    }
    

    
}