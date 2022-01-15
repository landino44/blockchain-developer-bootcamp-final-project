const emptyAddress = "0x0000000000000000000000000000000000000000";
const BN = web3.utils.BN;
const ParkingSystem = artifacts.require("ParkingSystem");

 

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ParkingSystem", function (accounts ) {
  it("Adds a Parcking Space and validates Owner Account.", async function () {
    
    let parkingSystem = await ParkingSystem.deployed();

    // Adds a new Parking space and charges registration fee
    let trx = await parkingSystem.addParkingSpace("ParkingSpace1", "Pueyrredón y Guido", 15, {from: accounts[1], value: 4});

    let ownerAccount = trx.logs[0].args._ownerAccount;
    // Validates the registered account of the space owner, is correct
    assert.equal(
      accounts[1],
      ownerAccount,
      "The Owner Account is not correct",
    );
  });

  it("Validates saved parking price.", async function () {
    
    let parkingSystem = await ParkingSystem.deployed();
    // Gets registered space info
    let info = await parkingSystem.getParkingSpaceInfoByName("ParkingSpace1");

    // Validates the registered price is correct
    assert.equal(
      info.price.toNumber(),
      15,
      "Saved parking price is not correct",
    );
  });  

  it("Creates a reservation and validates the result.", async function () {
    
    let parkingSystem = await ParkingSystem.deployed();

    // Makes the reservation and charges the reservation fee to the driver
    let trx = await parkingSystem.reserveParkingSpace("ParkingSpace1", {from:accounts[2], value: 1});
    // Gets the space info
    let info = await parkingSystem.getParkingSpaceInfoByName("ParkingSpace1");
    // Validates the space is already reserved
    assert.equal(
      info.isReserved,
      true,
      "Reservation failed",
    );
  }); 

  it("Finishes current reservation and validates the result.", async function () {
    
    let parkingSystem = await ParkingSystem.deployed();

    // Finishes current reservation and charges the its cost to the driver
    let trx = await parkingSystem.finishParking("ParkingSpace1", {from:accounts[2], value: 15});
    // Gets the space info
    let info = await parkingSystem.getParkingSpaceInfoByName("ParkingSpace1");
    // Validates the space is already reserved
    assert.equal(
      info.isReserved,
      false,
      "Reservation finalization failed",
    );
  }); 
});
