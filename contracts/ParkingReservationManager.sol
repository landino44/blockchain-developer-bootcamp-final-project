// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ParkingReservationManager is Ownable{

  //To create reservation Ids
  using Counters for Counters.Counter;
    Counters.Counter private reservationIndex;

  mapping(uint256 => Reservation) private reservations;

  enum Status {
    InProgress,
    Finished
  }

  struct Reservation {
    string spaceName;
    address ownerAccount;
    address driverAccount;
    Status status;
    uint256 value;
  }

  modifier AvailableToFinish(uint256 _reservationId){
    Status status = reservations[_reservationId].status;
    require(status == Status.InProgress, "Invalid reservation status.");
    _;
  }

  modifier OwnerCannotReserve(address _ownerAccount, address _driverAccount){
    require(_ownerAccount != _driverAccount, "Owner cannot reserve his own space");
    _;
  }

  constructor() {
    
  }

  function getParkingReservationInfo(uint256 _reservationId) public view returns ( string memory spaceName,
                                                                                    address ownerAccount,
                                                                                    address driverAccount,
                                                                                    Status status,
                                                                                    uint256 value) {

    Reservation memory res = reservations[_reservationId];

    return (res.spaceName,
            res.ownerAccount,
            res.driverAccount,
            res.status,
            res.value
           );
  }


  function reserveParkingSpace(string memory _spaceName, address _ownerAccount, address _driverAccount, uint256 _value) public onlyOwner OwnerCannotReserve(_ownerAccount, _driverAccount) returns (uint256) {

    reservationIndex.increment();
    reservations[reservationIndex.current()] = Reservation({
      spaceName: _spaceName,
      ownerAccount: _ownerAccount,
      driverAccount: _driverAccount,
      status: Status.InProgress,
      value: _value
    });

    return reservationIndex.current();
  }

  function finishParking(uint _reservationId) public onlyOwner{

    reservations[_reservationId].status = Status.Finished;
  }

}
