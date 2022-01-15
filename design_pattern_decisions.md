# Design Pattern Decisions
 ## Access Control Design Patternss

  ParkingReservationManager inherits the OpenZeppelin "Ownable" contract so that the sensitive functions of the application can only be accessed by the Owner of the contract.
  Ownable design pattern used in the function reserveParkingSpace() and finishParking().
  

 ## Inheritance and Interfaces 
  ParkingReservationManager contract inherits the OpenZeppelin Ownable contract to enable ownership for one managing user/party.
#