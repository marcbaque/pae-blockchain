import "./Organizer.sol";
import "./Ownable.sol";
//import "./TicketToken.sol";

contract Event is Ownable {
    
    enum EventStatus {Pending, Accepted, OnGoing, Finished, Success, Fail, Frozen, Cancelled}
    enum OrganizerStatus {Pending, Accepted, Success, Fail}
    enum PayStatus {Disabled, Enabled, Paid}
    enum RefundStatus {Disabled, Enabled, Paid}
    
    event EventStatusChanged(string status);
    event Frozen(string cause);
    
    uint public id;
    string public date;
    string public duration;
    
    EventStatus eventStatus;
    
    address[] organizers;

    mapping(address => uint) orgMapPercentage;
    mapping(address => OrganizerStatus) orgMapStatus;
    mapping(address => PayStatus) orgMapPayStatus;          //To check if they can get paid, or they were already paid.

    address[] clients;
    mapping(address => RefundStatus) clientMapRefundStatus;    //To check if they can be refunded, or they already were.
    

    address[] tickets;
    mapping(bytes32 => address) ticketMap;
    
 
    
    function Event(address _owner, uint _id, 
                   address[] _organizers, uint[] _percentage, 
                   string _date, string _duration, 
                   uint[] _ticketQuantity, uint[] _ticketValue, bytes32[] _ticketType) Ownable(_owner) {
        
        require(_organizers.length == _percentage.length);
        require(_ticketQuantity.length == _ticketValue.length && _ticketQuantity.length == _ticketType.length);

        id = _id;
        date = _date;
        duration = _duration;
        organizers = _organizers;
        
        for(uint i = 0; i < organizers.length; i++) {
            address organizer = organizers[i];
            orgMapPercentage[organizer] = _percentage[i]; 
            orgMapStatus[organizer] = OrganizerStatus.Pending;
            orgMapPayStatus[organizer] = PayStatus.Disabled;
        }

        for(i = 0; i < _ticketQuantity.length; i++) {
            bytes32 ticketType = _ticketType[i];
            TicketToken ticket = new TicketToken(_ticketQuantity[i], _ticketValue[i], ticketType);
            tickets.push(ticket);
            ticketMap[ticketType] = ticket;
        }

        eventStatus = EventStatus.Pending;
        
    }

    /************************************************************************************* 
     *  Ticket Functions
     */
    function buyTickets(bytes32 ticketType, uint amount) eventStatusIs(EventStatus.Accepted) {
        TicketToken ticket = TicketToken(ticketMap[ticketType]);
        ticket.assignTickets(msg.sender, amount);
        clients.push(msg.sender);
        clientMapRefundStatus[msg.sender] = RefundStatus.Disabled;
    }

    function getTicket(bytes32 ticketType) constant returns (address) {
        return ticketMap[ticketType];
    }


    /************************************************************************************* 
     * Status Functions
     */

    function pending() isEventOrganizer {

        require(orgMapStatus[msg.sender] == OrganizerStatus.Accepted && eventStatus < EventStatus.Accepted);
        orgMapStatus[msg.sender] = OrganizerStatus.Pending;

    } 

    function accept() isEventOrganizer {

        require(orgMapStatus[msg.sender] == OrganizerStatus.Pending);
        orgMapStatus[msg.sender] = OrganizerStatus.Accepted;
        
        if(organizersMatch(OrganizerStatus.Accepted)) {
            eventStatus = EventStatus.Accepted;
        }

    } 
    
    function cancel() onlyOwner {
        require(eventStatus <= EventStatus.Accepted);
        eventStatus = EventStatus.Cancelled;
        enableClientRefund();
    } 

    function start() {
        //Todo: Check is automatically called. 
        require(eventStatus == EventStatus.Accepted);
        //Todo: check now >= date
        eventStatus = EventStatus.OnGoing;

    }
    
    function end() {
        //Todo: Check is automatically called. 
        require(eventStatus == EventStatus.OnGoing);
        //Todo: check now >= date + duration
        eventStatus = EventStatus.Finished;
        
    }
    
    function success(bool eventSuccess) isEventOrganizer canVoteResult {
                  
        if(eventSuccess) {
            orgMapStatus[msg.sender] = OrganizerStatus.Success;
        } else { 
            orgMapStatus[msg.sender] = OrganizerStatus.Fail;
        }
        
        if(!organizersVotedEventResult()) {
            //Log("Todavia no han votado todos los organizadores")
            //Todo: Tener en cuenta que alguien no vote
            return;   
        }
        
        if(true /*votingTimeEnded()*/) {
            if(organizersMatch(OrganizerStatus.Success)) {
                if(true/*&& clientsHappy()*/) {
                    eventStatus = EventStatus.Success;
                    enablePayment();
                } else {
                    eventStatus = EventStatus.Frozen;
                    Frozen("Clients were not happy :(");
                }
                
            } else if (organizersMatch(OrganizerStatus.Fail)) {
                eventStatus = EventStatus.Fail;
                enableClientRefund();
            } else {
                eventStatus = EventStatus.Frozen;
                Frozen("Organizers disagreement.");
            }
        }
        
    } //Todo: Finish the method and any auxiliar method needed.

    function resolveFrozen() {

    } //Todo

    /************************************************************************************* 
     *  Payments and Refunds Functions
     */

    function enablePayment() internal {
        for(uint i = 0; i < organizers.length; i++) {
            orgMapPayStatus[organizers[i]] = PayStatus.Enabled;
        }
    } 

    function askPayment() isEventOrganizer canGetPaid {
        //uint payment = bsToken.balanceOf(this)*orgMapPercentage[msg.sender]; //aprox.
        //bsToken.transfer(this, msg.sender, payment)
        orgMapPayStatus[msg.sender] = PayStatus.Paid;
    } //Todo: Every BSToken Functionality

    function enableClientRefund() internal {
        for(uint i = 0; i < clients.length; i++) {
            clientMapRefundStatus[clients[i]] = RefundStatus.Enabled;
        }
    } 

    function askRefund() canGetRefund {
        // uint refund = 0;
        // for(uint i = 0; i < tickets.length; i++) {
        //     TicketToken ticket = TicketToken(tickets[i]);
        //     refund += ticket.numberTicketsUser(msg.sender) * ticket.value();
        // }
        //bsToken.transfer(this, msg.sender, refund)
        clientMapRefundStatus[msg.sender] = RefundStatus.Paid;
    } //Todo: Every BSToken Functionality
    
    /************************************************************************************* 
     *  Modifiers
     */

    modifier eventStatusIs(EventStatus evStatus) {
        require(eventStatus == evStatus);
        _;
    }
    modifier isEventOrganizer() {
        require(validOrganizer(msg.sender));
        _;
    }

    modifier canGetPaid() {
        require(orgMapPayStatus[msg.sender] == PayStatus.Enabled);
        _;
    }

     modifier canGetRefund() {
        require(clientMapRefundStatus[msg.sender] == RefundStatus.Enabled);
        _;
    }

    modifier canVoteResult() {
        require(orgMapStatus[msg.sender]==OrganizerStatus.Accepted 
        || orgMapStatus[msg.sender]==OrganizerStatus.Fail 
        || orgMapStatus[msg.sender]==OrganizerStatus.Accepted);

        _;
    }

    
    /************************************************************************************* 
     *  Auxiliar Functions
     */
    
    function validOrganizer(address _organizer) constant returns (bool) {
        for(uint i = 0; i < organizers.length; i++) {
            if(organizers[i] == _organizer) {
                return true;
            }
        }
        return false;
    }

    function organizersMatch(OrganizerStatus newStatus) internal constant returns (bool) {
        for(uint i = 0; i < organizers.length; i++) {
            if(orgMapStatus[organizers[i]] != newStatus) {
                return false;
            }
        }
        return true;
    }
    
    function organizersVotedEventResult() internal constant returns (bool) {
        for(uint i = 0; i < organizers.length; i++) {
            if(orgMapStatus[organizers[i]] != OrganizerStatus.Success
               && orgMapStatus[organizers[i]] != OrganizerStatus.Fail) {
                return false;
            }
        }
        return true;
    }
}