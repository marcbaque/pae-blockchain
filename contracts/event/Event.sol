pragma solidity ^0.4.18;

import "../ownership/Ownable.sol";
import "../token/TicketToken.sol";
import "../token/TicketTokenFactory.sol";
import "../bs-token/BSTokenFrontend.sol";
import "./EventData.sol";

contract Event is Pausable {

    enum EventStatus {Pending, Accepted, Opened, OnGoing, Finished, Success, Failed, Frozen, Cancelled}
    enum OrganizerStatus {Pending, Accepted, Success, Failed}

    uint public id;
    EventStatus public eventStatus;

    address[] public organizers;
    mapping (address => OrganizerInfo) public organizersInfo;

    struct OrganizerInfo {
        OrganizerStatus status;
        uint16 percentage;
    }

    address[] tickets;

    uint16 redButtonCounter = 0;
    uint public totalTickets = 0; 

    address ticketTokenFactory;
    address bsTokenFrontend;

    function Event(address _owner, address _bsTokenFrontend, address _ticketTokenFactory, uint _id) Pausable(_owner) public {
        id = _id;
        bsTokenFrontend = _bsTokenFrontend;
        ticketTokenFactory = _ticketTokenFactory;
    }

    function setTicketTokenFactory(address _ticketTokenFactory) {
        ticketTokenFactory = _ticketTokenFactory;
    }

    //Organizers 

    function getOrganizerAt(uint16 i) public constant returns (address) {
        return organizers[i];
    }

    function addOrganizer(address _organizerAddress, uint16 _percentage) public onlyOwner onlyWhen(0) whenNotPaused {
        organizers.push(_organizerAddress);
        organizersInfo[_organizerAddress] = OrganizerInfo(OrganizerStatus(0), _percentage);
    }

    //Tickets 

    function addTicket(uint8 _ticketType, uint16 _price, uint16 _quantity) public onlyOrganizer onlyWhen(0) whenNotPaused {
       tickets.push(TicketTokenFactory(ticketTokenFactory).createTicketToken(_ticketType,_price,_quantity));
    }

    function getAmountTicketTypes() public constant returns (uint) {
        return tickets.length;
    }

    function getTicket(uint16 i) public constant returns (address ticketToken) {
        return tickets[i];
    }

    function buyTickets(uint8 _ticketType, uint8 _amount) public onlyWhen(1) whenNotPaused {
        TicketToken _ticketToken = TicketToken(tickets[_ticketType]);
        uint256 totalPrice = _ticketToken.getValue() * _amount;
        BSTokenFrontend(bsTokenFrontend).transferFrom(msg.sender, this, totalPrice);
        _ticketToken.assignTickets(msg.sender, _amount);
        addTotalTickets(_amount);
    }

    function addTotalTickets(uint16 _value) public {
        totalTickets += _value;
    }

    //Status

    function getEventStatus() public constant returns (uint8) {
        return uint8(eventStatus);
    } 

    function setEventStatus(uint8 _eventStatus) public {
        eventStatus = EventStatus(_eventStatus);
    }

    function refundAResell(address _to, uint16 _quantity, uint8 _ticketType) public onlyTicket whenNotPaused {
        TicketToken _ticketToken = TicketToken(tickets[_ticketType]);
        uint totalPrice = _ticketToken.getValue() * _quantity;
        BSTokenFrontend(bsTokenFrontend).approve(_to, totalPrice);
    }

    function accept() public onlyOrganizer onlyWhen(0) whenNotPaused {
        OrganizerInfo orgInfo = organizersInfo[msg.sender];
        require(orgInfo.status == OrganizerStatus(0));
        organizersInfo[msg.sender] = OrganizerInfo(OrganizerStatus(1), orgInfo.percentage);

        if (organizersMatch(1)) setEventStatus(1);
    }

    function cancel() public onlyOrganizer onlyWhenRange([0, 1]) whenNotPaused {
        setEventStatus(8);
        activeRefund();
    }

    function open() public onlyOrganizer onlyWhen(1) whenNotPaused {
        setEventStatus(2);
    }

    function start() public onlyOwner onlyWhenRange([1,2]) whenNotPaused {
        setEventStatus(3);
    }

    function redButton() public onlyWhenRange([3,4]) {
        uint16 redButtonCount = 0;
        for (uint8 i = 0; i < tickets.length; i++) {
            redButtonCount = redButtonCount + TicketToken(tickets[i]).redButton(msg.sender);
        }
        redButtonCounter = redButtonCounter + redButtonCount;
    }

    function addRedButton(uint16 _value) public {
        redButtonCounter = redButtonCounter + _value;
    }

    function getRedButtonCounter() public constant returns (uint16) {
        return redButtonCounter;
    }

    function end() public onlyOwner onlyWhen(3) whenNotPaused {
        setEventStatus(4);
    }

    function evaluate(bool eventSuccess) public onlyOrganizer onlyWhen(4) {
        OrganizerInfo orgInfo  = organizersInfo[msg.sender];
        if (eventSuccess) { organizersInfo[msg.sender] = OrganizerInfo(OrganizerStatus(2), orgInfo.percentage);}
        else {organizersInfo[msg.sender] = OrganizerInfo(OrganizerStatus(3), orgInfo.percentage);}
    }

    function resolveEvaluation() public onlyWhen(4) {
        bool organizersEvaluationSuccess = organizersMatch(2);
        bool organizersEvaluationFailed = organizersMatch(3);
        bool clientsEvaluationSuccess = !(getRedButtonCounter() > totalTickets/4);
        if (organizersEvaluationFailed) { 
            setEventStatus(6); 
            activeRefund(); 
        } else if (organizersEvaluationSuccess && clientsEvaluationSuccess) { 
            setEventStatus(5); 
            activePayment(); 
        } else setEventStatus(7);
        //pauseTickets();
        
    }

    function resolveFrozen(bool success) public onlyOwner onlyWhen(7) {
        if (success) { setEventStatus(5); activePayment();  }
        else { setEventStatus(6); activeRefund(); }
    }

    modifier onlyWhen(uint8 evStatus) {
        require(EventStatus(getEventStatus()) == EventStatus(evStatus));
        _;
    }

    modifier onlyWhenRange(uint8[2] evStatus) {
        bool found = false;
        for(uint8 i = 0; i < evStatus.length; i++) {
            found = (evStatus[i] == getEventStatus());
            if (found) break;
        }
        require(found);
        _;
    }


    modifier onlyTicket() {
        bool found = false;
        for(uint8 i = 0; i < tickets.length; i++) {
            found = (tickets[i] == msg.sender);
            if (found) break;
        }
        require(found);
        _;
    }

    modifier onlyOrganizer() {
        bool found = false;
        for (uint i = 0; i < organizers.length; i++) {
            if (organizers[i] == msg.sender) found = true;
        }
        require(found);
        _;
    }

    function organizersMatch(uint8 status) internal constant returns (bool) {
        for (uint i = 0; i < organizers.length; i++) {
            OrganizerInfo orgInfo = organizersInfo[organizers[i]];
            if (orgInfo.status != OrganizerStatus(status)) return false;
        }
        return true;
    }

    function activePayment() internal onlyWhen(5) whenNotPaused {
        uint totalMoney = BSTokenFrontend(bsTokenFrontend).balanceOf(this);

        for (uint i = 0; i < organizers.length; ++i) {
            address orgAddress = organizers[i];
            OrganizerInfo orgInfo = organizersInfo[orgAddress];
            BSTokenFrontend(bsTokenFrontend).approve(orgAddress, totalMoney * orgInfo.percentage / 100);
        }
    }

    function activeRefund() internal whenNotPaused {
        require(getEventStatus() == 6 || getEventStatus() == 8);

        for (uint i = 0; i < tickets.length; ++i) {
            TicketToken _ticketToken = TicketToken(tickets[i]);
            uint16 _value = _ticketToken.getValue();

            uint numClients = _ticketToken.getNumberClients();
            for (uint16 j = 0; j < numClients; ++j) {
                address client = _ticketToken.getClientAt(j);
                uint256 totalMoney = _value * _ticketToken.balanceOf(client);
                BSTokenFrontend(bsTokenFrontend).approve(client, totalMoney);
            }
        }
    }

    function pauseTickets() internal  {
        for(uint8 i = 0; i < tickets.length; i++) (TicketToken(tickets[i]).pause());
    }

}
