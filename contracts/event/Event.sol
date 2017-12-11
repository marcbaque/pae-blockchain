pragma solidity ^0.4.2;

import "./../ownership/Ownable.sol";
import "./../token/TicketToken.sol";
import "./EventData.sol";

contract Event is MultiOwnable {

    EventData data;

    function Event(address _owner, address _subowner, EventData _eventData) MultiOwnable(_owner, _subowner) public {
        data = _eventData;
    }

    // Events for testing purposes
    event organizerInfoTest(uint id, address organizerAddress, uint status, uint16 percentage);

    /**
     * @dev Initializes the date and the duration of the event.
     * - onlySubowner It can only be accessed by Organizers, Owners and the contract itself.
     * - onlyWhen only accessible when event is "Status.Pending"
     * @param _date date of the event.
     * @param _duration duration of the event.
     */

    function initializeDate(uint _date, uint _duration)  public onlySubowner onlyWhen(0) {
        data.setDate(_date);
        data.setDuration(_duration);
    }

    /**
     * @dev Adds an organizer to the event (organizerStatus=>Pending).
     * - onlySubowner It can only be accessed by Organizers, Owners and the contract itself.
     * - onlyWhen only accessible when event is "Status.Pending"
     * @param _organizerAddress is the identifier of the organizer to add.
     * @param _percentage is the percentage of money a organizer will recive of the total benefit.
     */

    function addOrganizer(address _organizerAddress, uint16 _percentage) public onlySubowner onlyWhen(0) {
        data.addOrganizer(_organizerAddress, _percentage);
        addSubowner(_organizerAddress);
    }

    /**
     * @dev Adds a ticketType to the event.
     * - onlySubowner It can only be accessed by Organizers, Owners and the contract itself.
     * - onlyWhen only accessible when event is "Status.Pending"
     * @param _ticketType is the identifier of the type.
     * @param _price is the value of the ticket.
     * @param _quantity is the amount of tickets to create.
     */

    function addTicket(uint8 _ticketType, uint16 _price, uint16 _quantity) public onlySubowner onlyWhen(0) {
       TicketTokenData ticketTokenData = new TicketTokenData(_quantity, _price, _ticketType);
       TicketToken ticketToken = new TicketToken(owner, ticketTokenData);
       ticketTokenData.addLogic(address(ticketToken));
       data.addTicket(address(ticketToken));
    }








    function getEventStatus() returns (uint8) {
        return data.getEventStatus();
    }











    /**
     * @dev Gets the count of ticket types of the event.
     * @return the amount of types of the event.
     */

    function getAmountTicketTypes() public constant returns (uint) {
        return data.getNumberTickets();
    }

    /**
     * @dev Gets the ticket of type i.
     * @return the address of the ticketToken of type (i) of the event.
     */

    function getTicket(uint16 i) public constant returns (address ticketToken) {
        return data.getTicketAt(i);
    }

    /**
     * @dev Assings the msg.sender a certain amount of tickets and transfers the amount of
     *      bs-tokens required to the event.
     * - onlyWhen only accessible when event is "Status.Accepted".
     * - The user must have allowed Event to withdraw the amount of money required.
     */

    function buyTickets(uint8 ticketType, uint8 amount) public onlyWhen(1) {
        /* (BSTOKEN) transferFrom(msg.sender, this, ticketIndex[ticketType].data.getValue()); */
        TicketToken(data.getTicketAt(ticketType)).assignTickets(msg.sender, amount);
    }

    /**
     * @dev Allows the previous to refund the money of a resell.
     * - onlyOwner only accesible by the tickets.
     */

    function refundAResell(address _to, uint16 _quantity, uint8 ticketType) public onlyTicket {
        /* (BSTOKEN) approve(this, _to, tickets[ticketType].data.getValue() * _quantity); */
    }

    /**
     * @dev Allows the organizer(msg.sender) to accept the event conditions.
     * - onlySubowner It can only be accessed by subowners
     * - onlyWhen only accessible when event is "Status.Pending"
     * - only accessible when the organizer status is "Status.Pending"
     */

    function accept() public onlySubowner onlyWhen(0) {
        var (organizerStatus, percentage) = data.getOrganizerInfo(msg.sender);
        require(organizerStatus == 0);
        data.setOrganizerInfo(msg.sender, 1, percentage);

        if (organizersMatch(1)) data.setEventStatus(1);
    }

     /**
     * @dev Allows the organizer(msg.sender) to cancel the event. It also auto-activate the refund.
     * - onlySubowner It can only be accessed by subowners
     * - onlyWhenRange only accessible when event is "Status.Pending" or "Status.Accepted"
     */

    function cancel() onlySubowner public onlyWhenRange([0, 1]) {
        data.setEventStatus(8);
        activeRefund();
    }

    /**
     * @dev Allows the organizer(msg.sender) to open the event.
     * - onlySubowner It can only be accessed by subowners
     * - onlyWhen only accessible when event is "Status.Accepted"
     */

    function open() public onlySubowner onlyWhen(1) {
        data.setEventStatus(2);
    }

    /**
     * @dev Allows the organizer(msg.sender) to cancel the event. It also auto-activate the refund.
     * - onlySubowner It can only be accessed by subowners
     * - onlyWhenRange only accessible when event is "Status.Accepted" or "Status.Opened"
     */

    function start() public onlyOwner onlyWhenRange([1,2]) {
        data.setEventStatus(3);
    }

    /**
     * @dev Allows the user(msg.sender) to complain.
     * - onlyWhenRange only accessible when event is "Status.OnGoing" or "Status.Finished"
     */

    function redButton() public onlyWhenRange([3,4]) {
        uint16 redButtonCount = 0;
        for (uint8 i = 0; i < data.getNumberTickets(); i++) {
            redButtonCount += TicketToken(data.getTicketAt(i)).redButton(msg.sender);
        }
        data.redButtonPressed(redButtonCount);
    }

    /**
     * @dev Allows the owner(artistic island) to end the event.
     * - onlyOwner It can only be accessed by the Owner.
     * - onlyWhen only accessible when event is "Status.OnGoing".
     */

    function end() public onlyOwner onlyWhen(3) {
        data.setEventStatus(4);
    }

    /**
     * @dev Allows the organizers (msg.senders) to evaluate the event.
     * - onlySubowners It can only be accessed by the subowners/organizers.
     * - onlyWhen only accessible when event is "Status.Finished".
     */

    function evaluate(bool eventSuccess) public onlySubowner onlyWhen(4) {
        var (organizerStatus, percentage) = data.getOrganizerInfo(msg.sender);
        if (eventSuccess) data.setOrganizerInfo(msg.sender, 2, percentage);
        else data.setOrganizerInfo(msg.sender, 3, percentage);
    }

    /**
     * @dev Allows the owner(artistic island) to reslove the evaluations of the event.
     * - onlyOwner It can only be accessed by the Owner.
     * - onlyWhen only accessible when event is "Status.Finished".
     */

    function resolveEvaluation() public onlyOwner onlyWhen(4) {
        bool organizersEvaluationSuccess = organizersMatch(2);
        bool organizersEvaluationFailed = organizersMatch(3);
        bool clientsEvaluation = (data.getTotalTickets() - data.getRedButtonCount()) <= (data.getTotalTickets()/4);
        if (organizersEvaluationFailed) { data.setEventStatus(6); activeRefund(); pauseTickets(); }
        else if (organizersEvaluationSuccess && clientsEvaluation) { data.setEventStatus(5); activePayment(); }
        else data.setEventStatus(7);
    }

    /**
     * @dev Allows the owner(artistic island) to reslove the evaluations of the event.
     * - onlyOwner It can only be accessed by the Owner.
     * - onlyWhen only accessible when event is "Status.Frozen".
     */

    function resolveFrozen(bool success) public onlyOwner onlyWhen(7) {
        if (success) { data.setEventStatus(5); activePayment(); }
        else { data.setEventStatus(6); activeRefund(); }
    }

    /**
     * @dev Allows external action (for example,a test), to retrieve the info about the organizers of the
     * event via a solidity event.
     * - The event contains for each organizer: its number (for testing purposes), address, status and percentage
     */

    function testGetOrganizersInfo() {

        for (uint8 i = 0; i < data.getNumberOrganizers(); i++) {
            address org = data.getOrganizerAt(i);
            uint status;
            uint16 percentage;
            (status, percentage) = data.getOrganizerInfo(org);
            organizerInfoTest(i, org, status, percentage);
        }
    }

    function unpauseTickets() public onlyOwner {
        for(uint8 i = 0; i < data.getNumberTickets(); i++) (TicketToken(data.getTicketAt(i)).unpause());
    }

    modifier onlyWhen(uint8 evStatus) {
        require(data.getEventStatus() == evStatus);
        _;
    }

    modifier onlyWhenRange(uint8 [2] evStatus) {
        for(uint8 i = 0; i < evStatus.length; i++)
            require(data.getEventStatus() == evStatus[i]);
        _;
    }

    modifier onlySelfcall(){
        require(msg.sender == address(this));
        _;
    }

    modifier onlyTicket() {
        bool found = false;
        for(uint8 i = 0; i < data.getNumberTickets(); i++) {
            found = (data.getTicketAt(i) == msg.sender);
            if (found) break;
        }
        require(found);
        _;
    }

    function organizersMatch(uint8 status) internal constant onlySelfcall returns (bool) {
        for (uint i = 0; i < data.getNumberOrganizers(); i++) {
            var (organizerStatus,) = data.getOrganizerInfo(data.getOrganizerAt(i));
            if (organizerStatus != status) return false;
        }
        return true;
    }

    function activePayment() internal onlySelfcall onlyWhen(5) {
        /* foreach subowner, allowance (this, subowneraddress, totalmoney*percentage); */
    }

    function activeRefund() internal onlySelfcall {
        require(data.getEventStatus() == 6 || data.getEventStatus() == 8);
        /* foreach ticket, foreach client: allowance (this, clientaddress, value*balance); */
    }

    function pauseTickets() internal onlySelfcall {
        for(uint8 i = 0; i < data.getNumberTickets(); i++) (TicketToken(data.getTicketAt(i)).pause());
    }

}