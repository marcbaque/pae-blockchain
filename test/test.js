var UserFactory = artifacts.require("./UserFactory.sol");
var EventFactory = artifacts.require("./EventFactory.sol");
var Artist = artifacts.require("./Artist.sol");
var Organization = artifacts.require("./Organization.sol");
//var User = artifacts.require("./User.sol");
var EventContract = artifacts.require("./EventContract.sol");

var uf;
var ef;
var artists = [];

var art1;
var createdEvent;

var testLog;

contract("Test", function(accounts) {
    it("should create User&Event Factories and linking them to each other", function() {
        testLog ="------------------------------------------------------------------------------------\n\n";
        testLog += "Creation of User&Event Factories and link them to each other\n\n";
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
        });
    });

    it("should create two artists", function() {
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
        return uf.createArtist("Furi Helium", "666", "furihelium@gmail.com", {from: accounts[1]})
        .then(function(createdArtist) {
            //artist1 = createdArtist;
            setTimeout( () => artistCreated.stopWatching(), 2000);
            return uf.createArtist("Elias' band", "777", "eliasmola@gmail.com", {from: accounts[2]});
        });
    });

    it("artist1 should be able to create an event", function() {
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
        })
        
    });

    /* it("artist1 should be able to add artist2 as an organizer of the event", function() {

        return Artist.at(artists[2]).
        then(function(_art2) {
            art2 = _art2
            return art1.addOrganizerToEvent(createdEvent, art2);
        }).then(function(bool) {
            return createdEvent.organizers.call(0);
        }).then(function(_eventOrganizer1) {
            eventOrganizer1 = _eventOrganizer1;
            testLog += "Event organizer 2: " + eventOrganizer2);
        })
    }); */
});
