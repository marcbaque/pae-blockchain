let UserFactory = artifacts.require("./UserFactory.sol");
let EventFactory = artifacts.require("./EventFactory.sol");
let Artist = artifacts.require("./Artist.sol");
let Organization = artifacts.require("./Organization.sol");
let EventContract = artifacts.require("./EventContract.sol");

let uf;
let ef;
let artists = [];

let art1;
let art2;
let createdEvent;

let testLog;

contract("Test", function(accounts) {

    it("should create User&Event Factories and linking them to each other", async function() {

        testLog ="------------------------------------------------------------------------------------\n\n";
        testLog += "Creation of User&Event Factories and link them to each other\n\n";

        uf = await UserFactory.new({from: accounts[0]});
        testLog += "   UserFactory address: " + uf.address + "\n";

        ef = await EventFactory.new({from: accounts[0]});
        testLog += "   EventFactory address: " + ef.address + "\n\n";

        await ef.initializeUserFactory(uf.address,{from: accounts[0]});
        await uf.initializeEventFactory(ef.address,{from: accounts[0]});
        
        let ufStoredInEf = await ef.userFactory.call();
        testLog += "   UserFactory as stored in EventFactory: " + ufStoredInEf + "\n";
        assert(uf.address== ufStoredInEf, "UF in EF not valid");
        
        let efStoredInUf = await uf.eventFactory.call();
        testLog += "   EventFactory as stored in UserFactory: " + efStoredInUf + "\n\n";
        assert(ef.address== efStoredInUf, "EF in UF not valid");

    /*     OLD SCHOOL WAY:   
        return UserFactory.new({from: accounts[0]}).then(function(_uf) {
            uf = _uf;
            testLog += "   UserFactory address: " + uf.address + "\n";
            return EventFactory.new({from: accounts[0]});
        }).then(function(_ef) {
            ef = _ef;
            testLog += "   EventFactory address: " + ef.address + "\n\n";
            return ef.initializeUserFactory(uf.address,{from: accounts[0]});
        }).then(function() {
            return uf.initializeEventFactory(ef.address,{from: accounts[0]});
        }).then(function() {
            return ef.userFactory.call();
        }).then(function(ufStoredInEf) {
            testLog += "   UserFactory as stored in EventFactory: " + ufStoredInEf + "\n";
            assert(uf.address== ufStoredInEf, "UF in EF not valid");
            return uf.eventFactory.call();
        }).then(function(efStoredInUf) {
            testLog += "   EventFactory as stored in UserFactory: " + efStoredInUf + "\n\n";
            assert(ef.address== efStoredInUf, "EF in UF not valid");
        }); */
    
    }); 


    it("should create two artists", async function() {

        testLog += "------------------------------------------------------------------------------------\n\n";
        testLog += "Creation of artists\n\n";
        var artistCreated = uf.artistCreated();
        artistCreated.watch(function(err,result) {
            if(err) {
                console.log(err);
                return;
            }
            testLog += "    Artist " + result.args.length + ": " + result.args.artistAddress + "\n\n";
            artists.push(result.args.artistAddress);
            //testLog += "Artists array:  " + artists + "\n";
            
        });
        
        let createdArtist = await uf.createArtist("Furi Helium", "666", "furihelium@gmail.com", {from: accounts[1]});
        setTimeout( () => artistCreated.stopWatching(), 5000);
        await uf.createArtist("Elias' band", "777", "eliasmola@gmail.com", {from: accounts[2]});
    });

    it("artist1 should be able to create an event", async function() {

        art1 = await Artist.at(artists[1]);
        await art1.createEvent("Sabis Fest", "Description");
        createdEvent = await art1.events.call(0);
        setTimeout( () => {
            testLog += "------------------------------------------------------------------------------------\n\n";
            testLog += "Creation of an event\n\n"; 
            testLog += "    Address of the event: " + createdEvent + "\n\n";
            testLog += "------------------------------------------------------------------------------------\n\n"; 
        }, 1000);
        setTimeout( () => console.log(testLog), 1500);
        assert(createdEvent != null, "events del artista es nulo");

    /* OLD SCHOOL WAY:
        return Artist.at(artists[1]).
        then(function(_art1) {
            art1 = _art1;
            return art1.createEvent("Sabis Fest", "Description");
             
        }).then(function() {
            return art1.events.call(0);
        }).then(function(_createdEvent) {
            createdEvent = _createdEvent;
            setTimeout( () => {
                testLog += "------------------------------------------------------------------------------------\n\n";
                testLog += "Creation of an event\n\n"; 
                testLog += "    Address of the event: " + createdEvent + "\n\n";
                testLog += "------------------------------------------------------------------------------------\n\n"; 
            }, 1000);
            setTimeout( () => console.log(testLog), 1500);
            assert(createdEvent != null, "events del artista es nulo");
        }) */
        
    });

    
    it("artist1 should be able to add artist2 as an organizer of the event", async function() {
        art2 = await Artist.at(artists[2]);
        await art1.addOrganizerToEvent(createdEvent, art2);
        let eventOrganizer1 = await createdEvent.organizers.call(0);
        let eventOrganizer2 = await createdEvent.organizers.call(1);
        console.log("Event organizer 1: " + eventOrganizer1);
        console.log("Event organizer 2: " + eventOrganizer2);
    });
     
});
