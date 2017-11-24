let UserFactory = artifacts.require("./UserFactory.sol");
let EventFactory = artifacts.require("./EventFactory.sol");

let uf;

contract("UserFactory", function(accounts) {

    let basicUserCreated;
    let organizerCreated;

    before("creation of userFactory", async function () {
        uf = await UserFactory.new({from: accounts[0]});
        basicUserCreated = uf.basicUserCreated();
        organizerCreated = uf.organizerCreated();
    });


    it("should create a basic user", async function () {
        await uf.createBasicUser(accounts[1], 1);
        
        basicUserCreated.watch(function(err,result) {
            if(err) {
                console.log(err);
                return;
            }
            assert.equal(result.args.owner, accounts[1], "Owner no es el que se le ha pasado");
            console.log("Basic user created at address " + result.args.buAddress + " by " + result.args.owner);       
        });
    });

    it("should create an organizer", async function () {
        await uf.createOrganizer(2);
        
        organizerCreated.watch(function(err,result) {
            if(err) {
                console.log(err);
                return;
            }
            assert.equal(result.args.owner, accounts[0], "Owner no es el dueño de uf");            
            console.log("Organizer created at address " + result.args.organizerAddress + " by " + result.args.owner);         
        });
    });

    after("stop the watch for events", async function() {
        basicUserCreated.stopWatching();
        organizerCreated.stopWatching();
    });
})