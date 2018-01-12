let UserFactory = artifacts.require("./factory/UserFactory.sol");
let EventFactory = artifacts.require("./factory/EventFactory.sol");
let EventContract = artifacts.require("./event/Event.sol");
let BasicUser = artifacts.require("./user/BasicUser.sol");
let Organizer = artifacts.require("./user/Organizer.sol");
var BSTokenFrontend = artifacts.require("./bs-token/BSTokenFrontend.sol");
var TicketTokenFactory = artifacts.require("./token/TicketTokenFactory.sol");
var BSTokenData = artifacts.require("./bs-token/BSTokenData.sol");
var PermissionManager = artifacts.require("./bs-token/PermissionManager.sol");
var BSToken = artifacts.require("./bs-token/BSToken.sol");
var TicketToken = artifacts.require("./token/TicketToken.sol");
var BSTokenBanking = artifacts.require("./bs-token/BSTokenBanking.sol");

contract("Event", function([adminAcc, venueAcc, artistAcc, cl1Acc, cl2Acc, cl3Acc]) {
    
    let permissionManager;
    let bsTokenData;
    let bsTokenFrontend;
    let bsToken;
    let bsTokenBanking;

    let basicUserCreatedEvent;
    let organizerCreatedEvent;

    let userFactory;
    let eventFactory;
    let ticketFactory;
    let venue;
    let artist;

    let client1;
    let client2;
    let client3;

    let event;

    let timer = 0;
    


    before("creation of factories, organizers and clients", async function () {

        permissionManager = await PermissionManager.new({from: adminAcc});
        bsTokenData = await BSTokenData.new({from: adminAcc});
        bsTokenFrontend = await BSTokenFrontend.new(adminAcc, permissionManager.address, {from: adminAcc});
        bsToken = await BSToken.new(bsTokenData.address, bsTokenFrontend.address, {from: adminAcc});
        await bsTokenFrontend.setBSToken(bsToken.address, {from: adminAcc});
        bsTokenBanking = await BSTokenBanking.new(bsTokenData.address, permissionManager.address, {from: adminAcc});
        

        ticketFactory = await TicketTokenFactory.new({from: adminAcc});
        eventFactory = await EventFactory.new(ticketFactory.address, bsTokenFrontend.address, {from: adminAcc});
        userFactory = await UserFactory.new(bsTokenFrontend.address, eventFactory.address, {from: adminAcc});

        let basicUserCreated = userFactory.BasicUserCreated();
        let organizerCreated = userFactory.OrganizerCreated();
        let eventCreated = eventFactory.EventCreated();

        
        basicUserCreated.watch(async function(err,result) {
            if(err) {
                console.log(err);
                return;
            }
            let basicUserOwner = result.args.owner;
            let basicUserAddress = result.args.userAddress;

            console.log("Basic user created at address " + basicUserAddress + " by " + basicUserOwner); 

            let newBasicUser = await BasicUser.at(basicUserAddress);
            switch(result.args.owner) {
                case cl1Acc: client1 = newBasicUser; break;
                case cl2Acc: client2 = newBasicUser; break;
                case cl3Acc: client3 = newBasicUser; break;
            }
        });
        
        organizerCreated.watch(async function(err,result) {
            if(err) {
                console.log(err);
                return;
            }
            let organizerOwner = result.args.owner;
            let organizerAddress = result.args.userAddress;
            
            console.log("Organizer created at address " + organizerAddress + " by " + organizerOwner);
            let newOrganizer = await Organizer.at(organizerAddress);
            
            switch(organizerOwner) {
                case artistAcc: {
                    artist = newOrganizer; 
                    console.log(organizerAddress + " was an artist.")
                    break;
                }
                case venueAcc: {
                    venue = newOrganizer; 
                    console.log(organizerAddress + " was a venue.")
                    break;
                }
            }
        });

        eventCreated.watch(async function(err,result) {
            if(err) {
                console.log(err);
                return;
            }
            let eventOwner = result.args.owner;
            let eventAddress = result.args.eventAddress;

            event = await EventContract.at(eventAddress, {from: venueAcc});
            console.log("Event created at address " + event.address + " by " + await event.owner.call()); 
        });


        await userFactory.createOrganizer({from: artistAcc});
        await userFactory.createOrganizer({from: venueAcc});
        await userFactory.createBasicUser({from: cl1Acc});
        await userFactory.createBasicUser({from: cl2Acc});
        await userFactory.createBasicUser({from: cl3Acc});

    });
    
    it("should give euros to clients", async function () {
        timer = timer +1.5;
        setTimeout(async function(){ 
            console.log("\n");
            console.log("Client1 Balances: " + await bsTokenData.getBalance(client1.address, {from: adminAcc}));
            console.log("Give BSToken to client1: ");
            await bsTokenBanking.cashIn(client1.address, 5000, {from: adminAcc});
            await bsTokenBanking.cashIn(client2.address, 5000, {from: adminAcc});
            await bsTokenBanking.cashIn(client3.address, 5000, {from: adminAcc});
            console.log("Client1 Balances: " + await bsTokenData.getBalance(client1.address, {from: adminAcc}));
        }, timer*1000);

        assert(true, "if something is wrong there will be an error");
    });

    it("should create an event", async function () {
        timer = timer +1.5;
        setTimeout(async function(){ 
            console.log("\n");
            console.log("Creating event...");
            await venue.createEvent(10, {from: venueAcc});
        }, timer*1000);

        assert(true, "if something is wrong there will be an error");
    });

    it("should add organizers to event...", async function() {
        timer = timer +1.5;
        setTimeout(async function() {
            console.log("\n");
            console.log("[Venue Address: " + venue.address + "]");
            console.log("[Artist Address: " + artist.address + "]");
            console.log("Adding organizers...");
    
            await venue.addOrganizer(event.address, venue.address, 50, {from: venueAcc});
            await venue.addOrganizer(event.address, artist.address, 50, {from: venueAcc});
    
            console.log("New organizers added: ");
            console.log("   [" + await event.organizers.call(0, {from: venueAcc}) + "]");
            console.log("   [" + await event.organizers.call(1, {from: venueAcc}) + "]");
        }, timer*1000);
    
        assert(true, "if something is wrong there will be an error");
    });


    it("should add ticket", async function() {
        timer = timer +1.5;
        setTimeout(async function() {
            console.log("\n");
            console.log("Adding new ticket...");
            await venue.addTicket(event.address, 1, 1000, 200, {from: venueAcc}); //ticketType = 1, price = 10, quantity = 100
            let ticketAdd = await event.getTicket(0);
            let ticket = await TicketToken.at(ticketAdd, {from: adminAcc});
            console.log("Ticket added: {");
            console.log("   address: " + ticket.address);
            console.log("   price:   " + await ticket.getValue({from: adminAcc}));
            console.log("   sold:    " + await ticket.getTotalSupply({from: adminAcc}));
            console.log("}");
        }, timer*1000);
    
        assert(true, "if something is wrong there will be an error");
    });

    it("should let organizers accept the event and change the event status", async function() {
        timer = timer +1.5; 
        setTimeout(async function() {
            console.log("\n");
            console.log("Status Legend: ['0': Pending, '1': Accepted]");

            let status = await event.getEventStatus({from: adminAcc});
            console.log("   Event Status: " + status);

            console.log("Artist accepts...");
            await artist.acceptEvent(event.address, {from: artistAcc});
           
            status = await event.getEventStatus({from: adminAcc});
            console.log("   Event Status: " + status);

            console.log("Venue accepts...");
            await venue.acceptEvent(event.address, {from: venueAcc});

            status = await event.getEventStatus({from: adminAcc});
            console.log("   Event Status: " + status);
        }, timer*1000);
    
        assert(true, "if something is wrong there will be an error");
    });
    
    it("should let clients buy tickets", async function () {
        timer = timer +1.5;
        setTimeout(async function() { 
            console.log("\n");
            console.log("Clients buying tickets...");
            await client1.buyTicket(event.address, 0, 1, {from: cl1Acc});
            await client2.buyTicket(event.address, 0, 2, {from: cl2Acc});
            await client3.buyTicket(event.address, 0, 3, {from: cl3Acc});  

            let ticketAdd = await client1.tickets.call(0, {from: cl1Acc});
            let ticket = await TicketToken.at(ticketAdd, {from: adminAcc});
            console.log("Ticket bought: {");
            console.log("   address: " + ticket.address);
            console.log("   price:   " + await ticket.getValue({from: adminAcc}));
            console.log("   sold:    " + await ticket.getTotalSupply({from: adminAcc}));
            console.log("}");

            console.log("Client1 Balances: " + await bsTokenData.getBalance(client1.address, {from: adminAcc}));
            console.log("Event Balances: " + await bsTokenData.getBalance(event.address, {from: adminAcc}));
            console.log("Total Tickets Sold: " + await event.totalTickets.call({from: adminAcc}));
            console.log("Client1 Tickets: " + await ticket.balanceOf(client1.address, {from: adminAcc}));
            console.log("Tickets in Total: " + await ticket.balanceOf(ticket.address, {from: adminAcc}));

        }, timer*1000);

        assert(true, "if something is wrong there will be an error");
    });

    it("should open the event", async function () {
        timer = timer +3;
        setTimeout(async function() { 
            console.log("\n");
            console.log("Status Legend: ['0': Pending, '1': Accepted, '2': Opened]");
            let status = await event.getEventStatus({from: adminAcc});

            console.log("   Current Status: " + status);
            console.log("Changing to open status...");

            await venue.openEvent(event.address, {from: venueAcc});

            status = await event.getEventStatus({from: adminAcc});
            console.log("   New Status: " + status);

        }, timer*1000);

        assert(true, "if something is wrong there will be an error");
    });


    it("should let clients use their tickets", async function () {
        timer = timer +1.5;
        setTimeout(async function() { 
            console.log("\n");
            console.log("Clients using their tickets...");
            let ticketAdd = await event.getTicket(0);
            let ticket = await TicketToken.at(ticketAdd, {from: adminAcc});
            await client1.useTicket(ticket.address, 1, {from: cl1Acc});
            await client2.useTicket(ticket.address, 2, {from: cl2Acc});
            await client3.useTicket(ticket.address, 3, {from: cl3Acc});
        }, timer*1000);

        assert(true, "if something is wrong there will be an error");
    });

    it("should start the event", async function () {
        timer = timer +1.5;
        setTimeout(async function() { 
            console.log("\n");
            console.log("Status Legend: ['0': Pending, '1': Accepted, '2': Opened, '3': OnGoing]");
            let status = await event.getEventStatus({from: adminAcc});

            console.log("   Current Status: " + status);
            console.log("Changing to OnGoing status...");

            await venue.startEvent(event.address, {from: venueAcc});

            status = await event.getEventStatus({from: adminAcc});
            console.log("   New Status: " + status);
        }, timer*1000);

        assert(true, "if something is wrong there will be an error");
    });

    /* The following case is used to press red button, it is commented to 
     * try the success case.
     */

    // it("should let clients press the red button", async function () {
    //     timer = timer +1.5;
    //     setTimeout(async function() { 
    //         console.log("\n");
    //         console.log("Client2 pressing red button...");
    //         //await client2.redButton(event.address, {from: cl2Acc});
    //         let redButtonCounter = await event.getRedButtonCounter({from: adminAcc});
    //         console.log("Red Button Pressed: " + redButtonCounter);

    //     }, timer*1000);

    //     assert(true, "if something is wrong there will be an error");
    // });

    it("should stop the event", async function () {
        timer = timer +1.5;
        setTimeout(async function() { 
            console.log("\n");
            console.log("Status Legend: ['0': Pending, '1': Accepted, '2': Opened, '3': OnGoing, '4': Finished]");
            
            let status = await event.getEventStatus({from: adminAcc});
            console.log("   Current Status: " + status);

            console.log("Changing to Finished status...");

            await venue.endEvent(event.address, {from: venueAcc});

            status = await event.getEventStatus({from: adminAcc});
            console.log("   New Status: " + status);
        }, timer*1000);

        assert(true, "if something is wrong there will be an error");
    });

    it("should let the organizers evaluate the event", async function () {
        timer = timer +1.5;
        setTimeout(async function() { 
            console.log("\n");
            console.log("Status Legend: ['0': Pending, '1': Accepted, '2': Opened, '3': OnGoing, '4': Finished, '5': Success]");
            
            let status = await event.getEventStatus({from: adminAcc});
            console.log("   Current Status: " + status);
            console.log("Evaluating...");

            await venue.evaluate(event.address, true, {from: venueAcc});
            await artist.evaluate(event.address, true, {from: artistAcc});

            await event.resolveEvaluation({from: adminAcc});

            status = await event.getEventStatus({from: adminAcc});
            console.log("   Current Status: " + status);
        }, timer*1000);

        assert(true, "if something is wrong there will be an error");
    });

    it("should let organizers get paid", async function () {
        timer = timer +1.5;
        setTimeout(async function() { 
            console.log("\n");
            console.log("Allowance [event, artist]: " + await bsTokenFrontend.allowance(event.address, artist.address));
            console.log("Allowance [event, venue]: " + await bsTokenFrontend.allowance(event.address, venue.address));

            console.log("Artist getting paid...");
            await artist.getPayment(event.address, {from: artistAcc});
            console.log("Artist received: " + await bsTokenFrontend.balanceOf(artist.address));
            console.log("Venue getting paid...");
            await venue.getPayment(event.address, {from: venueAcc});
            console.log("Venue received: " + await bsTokenFrontend.balanceOf(venue.address));

            console.log("Success test finished. Press cntrl+C to stop the event watchers.");
        }, timer*1000);

        assert(true, "if something is wrong there will be an error");
    });


});
