var ParkingReservationManager = artifacts.require("./ParkingReservationManager.sol");
var ParkingSystem = artifacts.require("./ParkingSystem.sol");

module.exports = function(deployer) {
  deployer.deploy(ParkingReservationManager);
  deployer.deploy(ParkingSystem);
};