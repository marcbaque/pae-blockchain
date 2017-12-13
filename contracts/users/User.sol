pragma solidity ^0.4.0;

import "./../ownership/Ownable.sol";

contract User is Ownable{
    address internal _BSTokenFrontend;

    function User(address _bsTokenFrontend, address _owner) Ownable(_owner) {
        _BSTokenFrontend = _bsTokenFrontend;
    }
}
