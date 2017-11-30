import "./Organizer.sol";
import "./BasicUser.sol";
import "./Ownable.sol";
//import "./TicketToken.sol";

contract Event is Ownable {
    
    //enum EventStatus{Pending, Accepted, Open, OnGoing, Finished, Success, Failed, Frozen, Cancelled}
    enum EventStatus {Pending, Accepted, Opened, OnGoing, Finished, Success, Failed, Frozen, Cancelled}
    enum OrganizerStatus {Pending, Accepted, Success, Failed}

    // Events to watch from Artistic Island
    event EventStatusChanged(uint8 status);
    
    // Event Information
    uint public id;             
    uint public date;           //Unix time is a 32 bits variable, but 'now' is defined as uint.
    uint public duration;
    EventStatus eventStatus;
    
    //Organizers Information.
    Organizer[] organizers;
    mapping(address => OrganizerInfo) organizerInfo;

    struct OrganizerInfo {
        bool exists;
        OrganizerStatus status;
        uint16 percentage;
        bool paid;
    }

    //Clients Information.
    BasicUser[] clients;
    mapping(address => ClientInfo) clientInfo;

    struct ClientInfo {
        bool exists;
        bool redButton;
        bool refunded;
        //mapping(uint8 => uint8) ticketsBought;
    }

    //Tickets.
    TicketToken[] tickets;
    mapping(uint8 => TicketToken) ticketMap;
    
 
    
    function Event(address _owner, uint _id) Ownable(_owner) {
        
        id = _id;
        eventStatus = EventStatus.Pending;
        
    }

    /************************************************************************************* 
     *  Initialization
     */

    function initializeDate(uint _date, uint _duration) {
        date = _date;
        duration = _duration;
    }

    function addOrganizer(Organizer organizer, uint16 percentage) onlyOwner onlyInStatus(EventStatus.Pending) {
        organizers.push(organizer);
        bool paid = false;
        organizerInfo[organizer] = OrganizerInfo(true, OrganizerStatus.Pending, percentage, paid);
    }

    function addTicket(uint8 ticketType, uint16 price, uint16 quantity) onlyOwner onlyInStatus(EventStatus.Pending) {
        TicketToken ticket = new TicketToken(quantity, price, ticketType);
        tickets.push(ticket);
        ticketMap[ticketType] = ticket;
    }

    /************************************************************************************* 
     *  Ticket Functions
     */
    function buyTickets(uint8 ticketType, uint8 amount) onlyInStatus(EventStatus.Accepted) {
        TicketToken ticket = ticketMap[ticketType];
        //uint16 price = ticket.value() * amount;
        //Check bsToken.balanceOf(msg.sender) >= price;
        //bsToken.transfer(msg.sender, this, price);

        ticket.assignTickets(msg.sender, amount);
        clients.push(msg.sender);
        clientInfo[msg.sender] = ClientInfo(true, false, false);
    }

    function resellTickets() {
        //Todo: After MVP. 
    }

    function useTicket(uint8 ticketType) {
        require(eventStatus == EventStatus.Opened || eventStatus == EventStatus.OnGoing);
        require(clientInfo[msg.sender].exists);

        TicketToken ticket = ticketMap[ticketType];
        require(ticket.numberTicketsUser(msg.sender) > 0);
        ticket.useTicket(msg.sender);
    }

    /************************************************************************************* 
     * Status Functions
     */

    function pending() isEventOrganizer {

        require(organizerInfo[msg.sender].status == OrganizerStatus.Accepted && eventStatus == EventStatus.Pending);
        organizerInfo[msg.sender].status = OrganizerStatus.Pending;

    } 

    function accept() isEventOrganizer {

        require(organizerInfo[msg.sender].status == OrganizerStatus.Pending);
        organizerInfo[msg.sender].status = OrganizerStatus.Accepted;
        
        if(organizersMatch(OrganizerStatus.Accepted)) {
            eventStatus = EventStatus.Accepted;
        }

        EventStatusChanged(EventStatus.Accepted);

    } 
    
    function cancel() onlyOwner {
        require(eventStatus <= EventStatus.Accepted);
        eventStatus = EventStatus.Cancelled;
        EventStatusChanged(EventStatus.Cancelled);
    } 

    function open() {
        require(eventStatus == EventStatus.Accepted);
        eventStatus = EventStatus.Opened;
        EventStatusChanged(EventStatus.Opened);
    }

    function start() {
        //Todo: Check is automatically called. 
        require(eventStatus == EventStatus.Opened);
        //Todo: check now >= date
        eventStatus = EventStatus.OnGoing;
        EventStatusChanged(EventStatus.OnGoing);

    }
    
    function end() {
        //Todo: Check is automatically called. 
        require(eventStatus == EventStatus.OnGoing);
        //Todo: check now >= date + duration
        eventStatus = EventStatus.Finished;
        
    }
    
    function success(bool eventSuccess) isEventOrganizer canVoteResult {           
        if(eventSuccess) {
            organizerInfo[msg.sender].status = OrganizerStatus.Success;
        } else { 
            organizerInfo[msg.sender].status = OrganizerStatus.Failed;
        }
    }

    function redButton() isClient {
        if (clientInfo[msg.sender].redButton) {
            clientInfo[msg.sender].redButton = false;
        } else {
            clientInfo[msg.sender].redButton = true;
        }
    }

    function resolveSuccess(uint32 unixTime) onlyInStatus(EventStatus.Finished) {
        //Called by admin auto: date + duration + 1 hours;
        require(unixTime > date + duration + 45 minutes);

        if(organizersMatch(OrganizerStatus.Success)) {
            if(clientsAreHappy()) {
                eventStatus = EventStatus.Success;
                EventStatusChanged(EventStatus.Success);
            } else {
                eventStatus = EventStatus.Frozen;
                EventStatusChanged(EventStatus.Frozen);
            }
        } else if (organizersMatch(OrganizerStatus.Failed)) {
            eventStatus = EventStatus.Failed;
            EventStatusChanged(EventStatus.Failed);
        } else {
            eventStatus = EventStatus.Frozen;
            EventStatusChanged(EventStatus.Frozen);
        }
    }

    function resolveFrozen(bool success) {
        if (success) {
            eventStatus = EventStatus.Success;
            EventStatusChanged(EventStatus.Success);
        } else {
            eventStatus = EventStatus.Failed;
            EventStatusChanged(EventStatus.Failed);
        }
    } 

    /************************************************************************************* 
     *  Payments and Refunds Functions
     */

    function askPayment() isEventOrganizer canGetPaid {
        //uint payment = bsToken.balanceOf(this)*orgMapPercentage[msg.sender]; //aprox.
        //bsToken.transfer(this, msg.sender, payment)
        organizerInfo[msg.sender].paid = true;
    } //Todo: Every BSToken Functionality

    function askRefund() canGetRefund {
        uint refund = 0;
        for(uint i = 0; i < tickets.length; i++) {
            TicketToken ticket = tickets[i];
            refund += uint(ticket.numberTicketsUser(msg.sender)) * uint(ticket.value());
        }
        //bsToken.transfer(this, msg.sender, refund)
        clientInfo[msg.sender].refunded = true;
    } //Todo: Every BSToken Functionality
    
    /************************************************************************************* 
     *  Modifiers
     */

    modifier onlyInStatus(EventStatus evStatus) {
        require(eventStatus == evStatus);
        _;
    }
    modifier isEventOrganizer() {
        require(validOrganizer(msg.sender));
        _;
    }

    modifier isClient() {
        require(clientInfo[msg.sender].exists);
        _;
    }

    modifier canGetPaid() {
        require(eventStatus == EventStatus.Success);
        require(!organizerInfo[msg.sender].paid);
        _;
    }

     modifier canGetRefund() {
        require(eventStatus == EventStatus.Failed || eventStatus == EventStatus.Cancelled);
        require(clientInfo[msg.sender].exists);
        require(!clientInfo[msg.sender].refunded);
        _;
    }

    modifier canVoteResult() {
        require(eventStatus == EventStatus.Finished);
        require(organizerInfo[msg.sender].status==OrganizerStatus.Accepted 
        || organizerInfo[msg.sender].status==OrganizerStatus.Failed 
        || organizerInfo[msg.sender].status==OrganizerStatus.Accepted);

        _;
    }

    
    /************************************************************************************* 
     *  Auxiliar Functions
     */
    
    function validOrganizer(address _organizer) constant returns (bool) {
        return organizerInfo[_organizer].exists;
    }

    function clientsAreHappy() constant returns (bool) {
        uint16 redButton = 0;
        for (uint8 i = 0; i < clients.length; i++) 
            if (clientInfo[clients[i]].redButton) 
                redButton++;
        
        return (redButton * 100 / clients.length < 30);  
    }

    function organizersMatch(OrganizerStatus newStatus) internal constant returns (bool) {
        for (uint i = 0; i < organizers.length; i++) 
            if(organizerInfo[organizers[i]].status != newStatus) 
                return false;
    
        return true;
    }
    
    function organizersVotedEventResult() internal constant returns (bool) {
        for(uint i = 0; i < organizers.length; i++) {
            OrganizerStatus organizerStatus = organizerInfo[organizers[i]].status;
            if(!(organizerStatus == OrganizerStatus.Success || organizerStatus == OrganizerStatus.Failed)) {
                return false;
            }
        }
        return true;
    }
}