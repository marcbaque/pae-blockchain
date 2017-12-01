import "./Organizer.sol";
import "./BasicUser.sol";
import "./Ownable.sol";
import "./TicketToken.sol";

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
    Organizer[] public organizers;
    mapping(address => OrganizerInfo) organizerInfo;

    struct OrganizerInfo {
        //address addd;
        OrganizerStatus status;
        uint16 percentage;
        bool paid;
    }

    //Clients Information.
    BasicUser[] clients;
    mapping(address => ClientInfo) clientInfo;

    struct ClientInfo {
        bool redButton;
        bool refunded;
    }

    //Tickets.
    TicketToken[] tickets;
    mapping(uint8 => TicketToken) ticketMap;
    
 
    
    function Event(address _owner, uint _id) Ownable(_owner) {
        //Change Ownable, with  Artistic Island and Creator.
        id = _id;
        eventStatus = EventStatus.Pending;
    }


    /************************************************************************************* 
     *  Initialization
     */

    function initializeDate(uint _date, uint _duration) isOwner onlyWhen(EventStatus.Pending) {
        date = _date;
        duration = _duration;
    }

    function addOrganizer(Organizer organizer, uint16 percentage) onlyOwner onlyWhen(EventStatus.Pending) {
        organizers.push(organizer);
        bool paid = false;
        organizerInfo[organizer] = OrganizerInfo(true, OrganizerStatus.Pending, percentage, paid);
    }

    function addTicket(uint8 ticketType, uint16 price, uint16 quantity) onlyOwner onlyWhen(EventStatus.Pending) {
        TicketToken ticket = new TicketToken(quantity, price, ticketType);
        tickets.push(ticket);
        ticketMap[ticketType] = ticket;
    }


    /************************************************************************************* 
     *  Ticket Functions
     */
    function getTicketInformation(uint8 ticketType) constant returns (uint8, uint16, uint16, uint16) {
        Ticket ticket = ticketMap[ticketType];
        //Should return:
            //TicketType
            //Price
            //Number of tickets in total
            //Number of tickets available
        return (ticket.ticketType(), ticket.value(), ticket.cap(), ticket.totalSupply() /*+ ticket.totalResell()?*/);
    }
    function buyTickets(uint8 ticketType, uint8 amount) onlyWhen(EventStatus.Accepted) {
        //Should check the msg.sender is a BasicUser
        TicketToken ticket = ticketMap[ticketType];
        //uint16 price = ticket.value() * amount;
        //Check bsToken.balanceOf(msg.sender) >= price;
        //bsToken.transfer(msg.sender, this, price);

        ticket.assignTickets(msg.sender, amount);

        if (!clientExists(msg.sender)) {
            clients.push(msg.sender);
            clientInfo[msg.sender] = ClientInfo(false, false);    
        }
        
    }

    function resellTickets(uint8 ticketType, uint16 amount) onlyClient onlyWhen(EventStatus.Accepted){
        Ticket ticket = ticketMap[ticketType];
        ticket.approve(msg.sender, amount);
    }

    function refundFromResell() onlyClient {
        //Todo. Need to know number of tickets resold. 
        //Maybe add a mapping(BasicUser => moneyResell) in each ticket?
    }

    function useTicket(uint8 ticketType) onlyClient onlyDuring([EventStatus.Opened, EventStatus.OnGoing]) {
        require(eventStatus == EventStatus.Opened || eventStatus == EventStatus.OnGoing);
        TicketToken ticket = ticketMap[ticketType];
        ticket.useTicket(msg.sender);
    }


    /************************************************************************************* 
     * Status Functions
     */

    function pending() onlyOrganizer onlyWhen(EventStatus.Pending) {

        require(organizerInfo[msg.sender].status == OrganizerStatus.Accepted);
        organizerInfo[msg.sender].status = OrganizerStatus.Pending;

    } 

    function accept() onlyOrganizer onlyWhen(EventStatus.Pending) {

        require(organizerInfo[msg.sender].status == OrganizerStatus.Pending);
        organizerInfo[msg.sender].status = OrganizerStatus.Accepted;
        
        if(organizersMatch(OrganizerStatus.Accepted)) {
            eventStatus = EventStatus.Accepted;
            EventStatusChanged(EventStatus.Accepted);
        }
    } 
    
    function cancel() onlyOwner onlyDuring([EventStatus.Pending, EventStatus.Accepted]) {
        eventStatus = EventStatus.Cancelled;
        EventStatusChanged(EventStatus.Cancelled);
    } 

    function open() onlyWhen(EventStatus.Accepted) {
        eventStatus = EventStatus.Opened;
        EventStatusChanged(EventStatus.Opened);
    }

    function start() onlyWhen(EventStatus.Opened) {
        eventStatus = EventStatus.OnGoing;
        EventStatusChanged(EventStatus.OnGoing);
    }
    
    function end() onlyWhen(EventStatus.OnGoing) {
        eventStatus = EventStatus.Finished;
        EventStatusChanged(EventStatus.Finished);
        
    }
    
    function success(bool eventSuccess) onlyOrganizer onlyWhen(EventStatus.Finished) {           
        if(eventSuccess) {
            organizerInfo[msg.sender].status = OrganizerStatus.Success;
        } else { 
            organizerInfo[msg.sender].status = OrganizerStatus.Failed;
        }
    }

    function redButton() onlyClient onlyDuring([EventStatus.OnGoing, EventStatus.Finished]) {
        if (clientInfo[msg.sender].redButton) {
            clientInfo[msg.sender].redButton = false;
        } else {
            clientInfo[msg.sender].redButton = true;
        }
    }

    function resolveSuccess(uint32 unixTime) onlyWhen(EventStatus.Finished) {
        require(unixTime > date + duration + 1 hours);

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

    function resolveFrozen(bool success) onlyWhen(EventStatus.Frozen) {
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

    function askPayment() onlyOrganizer canGetPaid {
        //uint payment = bsToken.balanceOf(this)*organizerInfo[msg.sender].percentage / 100; //aprox.
        //bsToken.transfer(this, msg.sender, payment)
        organizerInfo[msg.sender].paid = true;
    } //Todo: Every BSToken Functionality

    function askRefund() onlyClient canGetRefund {
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

    modifier onlyWhen(EventStatus evStatus) {
        require(eventStatus == evStatus);
        _;
    }

    modifier onlyDuring(EventStatus[] status) {
        bool match = false;
        for(uint8 i = 0; i < status.length; i++) {
            if(eventStatus == status[i]) {
                match = true;
                break;
            }
        }
        if(!match) {
            revert()
        } else {
            _;
        }
    }

    modifier onlyOrganizer() {
        require(validOrganizer(msg.sender));
        _;
    }

    modifier onlyClient() {
        require(clientExists(msg.sender));
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

    
    /************************************************************************************* 
     *  Auxiliar Functions
     */
    
    function validOrganizer(address organizer) constant returns (bool) {
        return organizerInfo[organizer].exists;
    }

    function clientsAreHappy() constant returns (bool) {
        uint16 redButton = 0;
        for (uint8 i = 0; i < clients.length; i++) 
            if (clientInfo[clients[i]].redButton) 
                redButton++;
        
        return (redButton * 100 / clients.length < 30);  
    }

    function organizersMatch(OrganizerStatus status) internal constant returns (bool) {
        for (uint i = 0; i < organizers.length; i++) 
            if(organizerInfo[organizers[i]].status != status) 
                return false;
    
        return true;
    }
    
    function clientExists(address client) internal constant returns (bool) {
        for (uin16 i = 0; i < clients.length; i++) {
            if (client = clients[i]) {
                return true;
            }
        }
        return false;
    }
}