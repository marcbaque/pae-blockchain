import "./User.sol";

contract BasicUser is User {
    
    address[] tickets;
    
    function BasicUser(address _owner, bytes32 _id) User (_owner, _id) {
        
    }
    
    function getTickets() constant returns (address[]) {
        return tickets;
    }
    
    function buyTicket(address eventAddress, bytes32 ticketType) onlyOwner public {
        //Event e = Event(eventAddress);
        //TicketToken ticket = TicketToken(e.getTicket(ticketType); // El ticket que retorna esta funcion de quien es? Es un ticket de ejemplo?
        //if (this.bsTokens >= ticket.value) { // Ticket.value === Ticket.price?
        //  e.buyTicket(ticketType, 1);
        //  this.bsTokens = this.bsTokens - ticket.value;
        //}
    }
    
    function resellTicket(address ticketAddress) onlyOwner public {
        // Esto dijimos al final que se ponia el ticket en una cola para revenderlo, igual que se hace con los asientos del Barcelona?
        //TicketToken t = TicketToken(ticketAddress);
        //t.resell(); // Esto deberia soltar un evento cuando se venda para hacerle el ingreso de los tokens al BasicUser?

        //t.ResellEvent((error, result) => {
        //    if (!error && result.ticketAddress === ticketAddress) {
        //      this.bsTokens = this.bsTokens + result.value;
        //    }
        //})
    }
    
    function redButton(address ticketAddress) {
        //TicketToken t = TicketToken(ticketAddress);
        //t.redButton();
    }

    function askRefund(address ticketAddress) {
        //TicketToken t = TicketToken(ticketAddress);
        //t.askRefund();

        //t.RefundEvent((error, result) => {
        //    if (!error && result.ticketAddress === ticketAddress) {
        //      this.bsTokens = this.bsTokens + result.value;
        //    }
        //})
    }
}