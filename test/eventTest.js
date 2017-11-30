let UserFactory = artifacts.require("./UserFactory.sol");
let EventFactory = artifacts.require("./EventFactory.sol");
let Event = artifacts.require("./Event.sol");
let BasicUser = artifacts.require("./BasicUser.sol");
let Organizer = artifacts.require("./Organizer.sol");

contract("Event", function([adminAcc, venueAcc, artistAcc, cl1Acc, cl2Acc, cl3Acc]) {
    
    let basicUserCreatedEvent;
    let organizerCreatedEvent;

    let uf;
    let ef;
    let venue;
    let artist;

    let client1;
    let client2;
    let client3;

    let event;

    before("creation of factories, organizers and clients", async function () {
        uf = await UserFactory.new({from: adminAcc});
        ef = await EventFactory.new({from: adminAcc});

        await uf.createOrganizer(01, {from: artistAcc});
        await uf.createOrganizer(02, {from: venueAcc});

        await uf.createBasicUser(10, {from: cl1Acc});
        await uf.createBasicUser(11, {from: cl2Acc});
        await uf.createBasicUser(12, {from: cl3Acc});
        
        let basicUserCreated = uf.basicUserCreated();
        let organizerCreated = uf.organizerCreated();

        basicUserCreated.watch(function(err,result) {
            if(err) {
                console.log(err);
                return;
            }
            let basicUserOwner = result.args.owner;
            let basicUserAddress = result.args.buAddress;

            console.log("Basic user created at address " + basicUserAddress + " by " + basicUserOwner); 

            switch(result.args.owner) {
                case cl1Acc: client1 = basicUserAddress; break;
                case cl2Acc: client2 = basicUserAddress; break;
                case cl3Acc: client3 = basicUserAddress; break;
            }
        });

        organizerCreated.watch(function(err,result) {
            if(err) {
                console.log(err);
                return;
            }
            let organizerOwner = result.args.owner;
            let organizerAddress = result.args.organizerAddress;
            
            console.log("Organizer created at address " + result.args.organizerAddress + " by " + organizerOwner);
            await organizerOwner.setEventFactory(ef);
            
            switch(organizerOwner) {
                case artistAcc: artist = organizerAddress; break;
                case venueAcc: venue = organizerAddress; break;
            }

        });

    });

    it("should create an event", async function () {
        
        let eventCreated = ef.eventCreated();
        await ef.createEvent({from: artistAcc});
        eventCreated.watch(function(err,result) {
            if(err) {
                console.log(err);
                return;
            }
            let eventOwner = result.args.owner;
            let eventAddress = result.args.buAddress;

            event = eventAddress;
            console.log("Event created at address " + eventAddress + " by " + eventOwner); 
            
            await event.initializeDate(1512680400, 7200, {from: artistAcc}); // date  is 7/12/2017 at 21:00h, duration is 2h (7200 s)
            await event.addOrganizer(artistAcc, 50, {from: artistAcc});
            await event.addOrganizer(venueAcc, 50, {from: artistAcc});
            await event.addTicket(1, 10, 200, {from: artistAcc}); //ticketType = 1, price = 10, quantity = 100
            await event.accept({from: artistAcc});
            await event.accept({from: venueAcc});
            
            console.log("\nEvent date is: "+ event.date.call());
            console.log("\nEvent duration is: "+ event.duration.call());
            let retrievedOrganizer1 = event.organizers.call(0);
            let retrievedOrganizer2 = event.organizers.call(1);
            console.log("\nEvent organizers are:\n\t" + retrievedOrganizer1 + "\n\t" + retrievedOrganizer2);
            
        });


    })
});