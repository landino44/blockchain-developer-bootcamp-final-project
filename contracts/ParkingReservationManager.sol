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
    Registered,
    InProgress,
    Cancelled,
    Finished,
    Payed
  }

  struct Reservation {
    string spaceName;
    address ownerAccount;
    address driverAccount;
    Status status;
  }

  modifier Registered(uint256 _reservationId){
    require(reservations[_reservationId].status == Status.Registered, "Invalid reservation status.");
    _;
  }

  modifier AvailableToCancel(uint256 _reservationId){
    Status status = reservations[_reservationId].status;
    require(status == Status.Registered || status == Status.InProgress, "Invalid reservation status.");
    _;
  }

  modifier AvailableToFinish(uint256 _reservationId){
    Status status = reservations[_reservationId].status;
    require(status == Status.InProgress, "Invalid reservation status.");
    _;
  }

  constructor() {
    
  }

  function reserveParkingSpace(string memory _spaceName, address _ownerAccount, address _driverAccount) public onlyOwner returns (uint256) {

    reservationIndex.increment();
    reservations[reservationIndex.current()] = Reservation({
      spaceName: _spaceName,
      ownerAccount: _ownerAccount,
      driverAccount: _driverAccount,
      status: Status.Registered
    });

    return reservationIndex.current();
  }

  function startParking(uint _reservationId) public Registered(_reservationId) onlyOwner{

    reservations[_reservationId].status = Status.InProgress;
  }

  function cancelParking(uint _reservationId) public AvailableToCancel(_reservationId) onlyOwner{

    reservations[_reservationId].status = Status.Cancelled;
    //falta impactar algun fee por la cancelación
  }

    function finishParking(uint _reservationId) public AvailableToFinish(_reservationId) onlyOwner{

    reservations[_reservationId].status = Status.Finished;
    //falta impactar el pago
  }

}
