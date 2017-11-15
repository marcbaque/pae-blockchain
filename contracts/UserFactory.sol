pragma solidity ^0.4.15;

import "./User.sol";
import "./Artist.sol";
import "./EventFactory.sol";

contract UserFactory {
    
    address owner;
    EventFactory public eventFactory;

    enum OrganizationEnum {None, Artist, Venue}

    mapping(address => address) ownerMapUser; 
    mapping(address => OrganizationEnum) userMapOrganization;
    mapping(string => bool) phoneMapRegistered;

    User[] public userList;
    Artist[] public artistList;

    event artistCreated(address artistAddress, uint length); 

    function UserFactory () {
        owner = msg.sender;
    }

    function initializeEventFactory(address eventFactoryAddress) onlyOwner {
        EventFactory ef = EventFactory(eventFactoryAddress);
        eventFactory = ef;
    } 
    // Modfiers
    
    modifier isNotRegistered(string _phone) {
        require(ownerMapUser[msg.sender] == 0 && phoneMapRegistered[_phone]==false);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    //Functions
    function createBasicUser(string _name, string _phone, string _email) isNotRegistered(_phone) returns (User) {

        //En un futuro quizas interese hacer otro modifier: registrationAllowed. De manera que desde frontend se le 
        //indique al usuario algun codigo y si este lo indica pues entonces los admin puedan decir: este numero de telefono
        //puede ahora si registrarse

        User user = new User(msg.sender,userList.length, _name, _phone, _email);

        ownerMapUser[msg.sender] = user;
        phoneMapRegistered[_phone] = true;
        userMapOrganization[user] = OrganizationEnum.None;
        userList.push(user);

        return user;
    }
    

    function createArtist(string _name, string _phone, string _email) isNotRegistered(_phone) returns (Artist) {
        Artist artist = new Artist(msg.sender,userList.length, _name, _phone, _email, eventFactory);

        ownerMapUser[msg.sender] = artist;
        phoneMapRegistered[_phone] = true;
        userMapOrganization[artist] = OrganizationEnum.Artist;

        userList.push(artist); 
        artistList.push(artist);

        artistCreated(artist, userList.length);

        return artist;
    }

    function getMyUser() constant returns (address) {
        return ownerMapUser[msg.sender];
    } 
    
    function getUserById(uint id) constant returns (User userAddress, OrganizationEnum userOrganizationType) {
        return (userList[id], userMapOrganization[userList[id]]);
    }
    
    function isOrganization(address userAddress /*User Contract Address, Not the Pk of the owner of the User*/) returns (bool) {
        if (userMapOrganization[userAddress] != OrganizationEnum.None) {
            return true;
        } else {
            return false;
        }
    }
    
}
