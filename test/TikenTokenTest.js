const TicketToken = artifacts.require('TicketToken');

contract('TicketToken', function (accounts) {
  let initialSupply = 100;
  let ticketPrice = 10;
  let ticketType = 0;
  let ticket;

  it('Should create a TicketToken for an event', function () {
    return TicketToken.new(accounts[1], initialSupply, ticketPrice, ticketType).then(function (instance) {
      ticket = instance;
    }).catch(function (error) {
      assert.error(error);
    })
  });

  it('Should return event address', function() {
    return ticket.getEvent.call(accounts[0]);
  }).then(function (owner) {
    assert.equals(owner, accounts[1], 'Owner is not set to event parameter')
  });

  it('Should return total supply', function () {
    return ticket.getCap.call(accounts[0]);
  }).then(function (totalSupply) {
    assert.equals(totalSupply, initialSupply, 'TotalSupply is not set to initialSupply')
  });

  it('Should return ticket value', function () {
    return ticket.getValue.call(accounts[0]);
  }).then(function (value) {
    assert.equals(value, ticketPrice, 'Ticket value is not set to ticketPrice')
  });

  it('Should return balance of an account', function () {
    return ticket.balanceOf.call(accounts[0], accounts[0]);
  }).then(function (balance) {
    assert.equals(balance, 0, 'Balance is not zero')
  });

  it('Should transfer ticket from an account to another', function () {
    if(ticket.transfer(accounts[1], 1)) {
      return ticket.balanceOf.call(accounts[1], accounts[0]);
    }
    else assert.error('Ticket not transfered');
  }).then(function (balance) {
    assert.equals(balance, 1, 'Balance is not zero')
  });

  it('Should give allowance', function () {
    // allowance doesnt have an address parameter to give it allowance
  });

  it('Should transfer from an account to another', function () {

  });
});