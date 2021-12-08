const ParkingReservationManager = artifacts.require("ParkingReservationManager");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ParkingReservationManager", function (/* accounts */) {
  it("should assert true", async function () {
    await ParkingReservationManager.deployed();
    return assert.isTrue(true);
  });
});
