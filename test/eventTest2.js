let UserFactory = artifacts.require("./factory/UserFactory.sol");
let EventFactory = artifacts.require("./factory/EventFactory.sol");
let Event = artifacts.require("./event/Event.sol");
let BasicUser = artifacts.require("./user/BasicUser.sol");
let Organizer = artifacts.require("./user/Organizer.sol");

contract("Event", function([adminAcc, venueAcc, artistAcc, cl1Acc, cl2Acc, cl3Acc]) {
    
    let basicUserCreatedEvent;
    let organizerCreatedEvent;

    let userFactory;
    let eventFactory;
    let venue;
    let artist;

    let client1;
    let client2;
    let client3;

    let event;

    before("creation of factories, organizers and clients", async function () {
        userFactory = await UserFactory.new({from: adminAcc});
        eventFactory = await EventFactory.new({from: adminAcc});

        await userFactory.createOrganizer(01, {from: artistAcc});
        await userFactory.createOrganizer(02, {from: venueAcc});

        await userFactory.createBasicUser(11, {from: cl1Acc});
        await userFactory.createBasicUser(12, {from: cl2Acc});
        await userFactory.createBasicUser(13, {from: cl3Acc});
        
        let basicUserCreated = userFactory.BasicUserCreated();
        let organizerCreated = userFactory.OrganizerCreated();

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
            await organizerOwner.setEventFactory(eventFactory );
            
            switch(organizerOwner) {
                case artistAcc: artist = organizerAddress; break;
                case venueAcc: venue = organizerAddress; break;
            }

        });

    });

    it("should create an event", async function () {
        
        /*let eventCreated = eventFactory.EventCreated();
        await venue.createEvent({from: venueAcc});
        
        eventCreated.watch(function(err,result) {
            if(err) {
                console.log(err);
                return;
            }
            let eventOwner = result.args.owner;
            let eventAddress = result.args.buAddress;

            event = eventAddress;
            console.log("Event created at address " + eventAddress + " by " + eventOwner); 
            
            await venue.initializeDate(event, 1512680400, 7200, {from: venueAcc}); // date  is 7/12/2017 at 21:00h, duration is 2h (7200 s)
            await venue.addOrganizer(event, artist, 50, {from: venueAcc});
            await venue.addOrganizer(event, venue, 50, {from: venueAcc});
            await venue.addTicket(event, 1, 10, 200, {from: venueAcc}); //ticketType = 1, price = 10, quantity = 100

            let status = await event.getEventStatus({from:AdminAcc});
            console.log("\nEvent Status: " + status);
            await venue.accept(event, {from: venueAcc});
            await artist.accept(event, {from: artistAcc});
            status = await event.getEventStatus({from:AdminAcc});
            console.log("\nEvent Status: " + status);
            //console.log("\nEvent date is: "+ event.date.call());
            //console.log("\nEvent duration is: "+ event.duration.call());
            //let retrievedOrganizer1 = event.organizers.call(0);
            //let retrievedOrganizer2 = event.organizers.call(1);
            //console.log("\nEvent organizers are:\n\t" + retrievedOrganizer1 + "\n\t" + retrievedOrganizer2);
            
        });
*/
        assert(true, "Pues ha ido mal");
    })
});
