import "./Organizer.sol";
import "./Ownable.sol";
//import "./TicketToken.sol";

contract Event is Ownable {
    
    enum EventStatus {Pending, Accepted, OnGoing, Finished, Success, Fail, Frozen}
    enum OrganizerStatus {Pending, Accepted, Success, Fail}
    enum PayStatus {Disabled, Enabled, Paid}
    
    event Frozen(string cause);
    
    uint public id;
    string public date;
    string public duration;
    
    EventStatus eventStatus;
    
    address[] organizers;
    mapping(address => uint) orgMapPercentage;
    mapping(address => EventStatus) orgMapStatus;
    mapping(address => PayStatus) orgMapPayStatus;
    
    
    address ticketAddress;
    
 
    
    function Event(address _owner, uint _id, address[] _organizers, uint[] _percentage, string _date, string _duration/*, TicketToken _ticket*/) Ownable(_owner){
        require(_organizers.length == _percentage.length);
        
        id = _id;
        date = _date;
        duration = _duration;
        organizers = _organizers;
        
        for(uint i = 0; i < organizers.length; i++) {
            address organizer = organizers[i];
            orgMapPercentage[organizer] = _percentage[i]; 
            orgMapStatus[organizer] = EventStatus.Pending;
            orgMapPayStatus[organizer] = PayStatus.Disabled;
        }
        
        eventStatus = EventStatus.Pending;
        
    }
    
    
    
    function accept() {
        require(isEventOrganizer(msg.sender));
        require(orgMapStatus[msg.sender]==EventStatus.Pending);
        orgMapStatus[msg.sender]==EventStatus.Accepted;
        
        if(organizersMatch(EventStatus.Accepted)) {
            eventStatus = EventStatus.Accepted;
        }
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
    
    function success(bool eventSuccess) {
        //Todo: check eventSuccess not null
        require(isEventOrganizer(msg.sender));
        require(orgMapStatus[msg.sender]==EventStatus.Accepted 
                /*|| orgMapStatus[msg.sender]==EventStatus.Fail
                  || orgMapStatus[msg.sender]==EventStatus.Accepted*/);
                  
        if(eventSuccess) orgMapStatus[msg.sender] = EventStatus.Success;
        else orgMapStatus[msg.sender] = EventStatus.Fail;
        
        if(!organizersVotedSuccessStatus()) {
            //Log("Todavia no han votado todos los organizadores")
            //Todo: Tener en cuenta que alguien no vote
            return;   
        }
        
        if(true /*votingTimeEnded()*/) {
            if(organizersMatch(EventStatus.Success)) {
                if(true/*&& clientsHappy()*/) {
                    eventStatus = EventStatus.Success;
                    enablePayment();
                } else {
                    eventStatus = EventStatus.Frozen;
                    Frozen("Clients were not happy :(");
                }
                
            } else if (organizersMatch(EventStatus.Fail)) {
                eventStatus = EventStatus.Fail;
                enableClientsRefund();
            } else {
                eventStatus = EventStatus.Frozen;
                Frozen("Organizers disagreement.");
            }
        }
        
    }
    
    function askPayment() {
        require(isEventOrganizer(msg.sender)); 
        require(orgMapPayStatus[msg.sender] == PayStatus.Enabled);
        //BSToken.transfer(this, msg.sender)
        orgMapPayStatus[msg.sender] = PayStatus.Paid;
    }
    
    function enablePayment() internal {
        //TODO: Add Modifier onlySuccess
        for(uint i = 0; i < organizers.length; i++) {
            orgMapPayStatus[organizers[i]] = PayStatus.Enabled;
        }
    }
    
    function enableClientsRefund() internal {
        //TODO
    }
    
    function organizersMatch(EventStatus newStatus) internal constant returns (bool) {
        for(uint i = 0; i < organizers.length; i++) {
            if(orgMapStatus[organizers[i]] != newStatus) {
                return false;
            }
        }
        return true;
    }
    
    function organizersVotedSuccessStatus() internal constant returns (bool) {
        for(uint i = 0; i < organizers.length; i++) {
            if(orgMapStatus[organizers[i]] != EventStatus.Success
               && orgMapStatus[organizers[i]] != EventStatus.Fail) {
                return false;
            }
        }
        return true;
    }
    
    function isEventOrganizer(address _organizer) constant returns (bool) {
        for(uint i = 0; i < organizers.length; i++) {
            if(organizers[i] == _organizer) {
                return true;
            }
        }
        return false;
    }
    
    
    
    
    
}