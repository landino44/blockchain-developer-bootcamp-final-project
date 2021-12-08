// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ParkingReservationManager.sol";


contract ParkingSystem is Ownable {
  
  struct ParkingSpaceOwner {
    uint256 id;
    string name;
    address account;
  }

  struct ParkingSpace {
    string name;
    string locationAddress;
    uint256 ownerId;  
    uint price;
    bool isReserved;     
  }
  
  struct Driver {
    uint256 id;
    string name;
    address account;
  }

  //It verifies the new owner does not already enrolled
  modifier NotEnrolledOwner(string memory _ownerName) {
    uint256 ownerId = ownerIdByName[_ownerName];
    require(enrolledOwners[ownerId] == false, "User already exists." );
    _;
  }

  //Check if exists an owner id _ownerId
  modifier EnrolledOwner(uint256 _ownerId) {
    //require(enrolledOwners[_ownerId], "Does not exist an Owner with provided owner id.");
    require(true, "Does not exist an Owner with provided owner id.");
    _;
  }

  //It verifies the new driver does not already enrolled
  modifier NotEnrolledDriver(string memory _driverName) {
    uint256 driverId = driverIdByName[_driverName];
    require(enrolledDrivers[driverId] == false, "Driver already exists." );
    _;
  }

  //Check if exists an driver id _driverId
  modifier EnrolledDriver(uint256 _driverId) {
    require(enrolledDrivers[_driverId], "Does not exist an Driver with provided driver id.");
    _;
  }

  //It verifies the new space has not been registered
  modifier NonExistentParkingSpace(string memory _parkingName) {
    require(registeredSpaces[_parkingName] == false, "Space already exists." );
    _;
  }

  //It verifies the new space has not been registered
  modifier ExistentParkingSpace(string memory _parkingName) {
    require(registeredSpaces[_parkingName], "Space does not exist." );
    _;
  }

  modifier CorrectEnrollmentAmount() {
    require(msg.value == enrollmentFee, "The value must be equal to the enrollment fee.");
    _;
  }

  modifier CorrectSpacePublicationAmount() {
    require(msg.value == spacePublicationFee, "The value must be equal to the space publication fee.");
    _;
  }

  modifier CorrectReservationAmount() {
    require(msg.value == reservationFee, "The value must be equal to the reservation fee.");
    _;
  }

  uint private constant enrollmentFee = 5;
  uint private constant spacePublicationFee = 4; 
  uint private constant reservationFee = 1;


  ///**** Owners
  //To create owner Ids
  using Counters for Counters.Counter;
    Counters.Counter private ownersIndex;
  //Owners by Id. Key: owner Id, Value: ParkingSpaceOwner
  mapping(uint256 => ParkingSpaceOwner) private ownersById;  
  ParkingSpaceOwner[] private spaceOwners;
  //Owner name to Id
  mapping(string => uint256) ownerIdByName;
  //Allows to know if a owner is already enrolled. Key: owner Id, Value: indicates if the owner is enrolled or not 
  mapping(uint256 => bool) private enrolledOwners;

  ///**** Drivers
  //To create driver Ids
  using Counters for Counters.Counter;
    Counters.Counter private driversIndex;
  //Drivers by Id. Key: driver Id, Value: Driver
  mapping(uint256 => Driver) private driversById;  
  //Driver name to Id
  mapping(string => uint256) driverIdByName;
  //Allows to know if a driver is already enrolled. Key: driver Id, Value: indicates if the driver is enrolled or not 
  mapping(uint256 => bool) private enrolledDrivers;
  //Cars to driver
  mapping(string => uint256) carsToDriver;



  ///**** Spaces
  //Availables Parking Spaces. Key: space name, Value: the parking space
  mapping(string => uint256)  private parkingSpaces;
  ParkingSpace[] private spaces;
  using Counters for Counters.Counter;
    Counters.Counter private spaceCount;
  //Allows to know if the space has been registered in the app. Key: space Id, Value: indicates if the space exists or not
  mapping(string => bool) private registeredSpaces;
  //Allows to know easily the owner for each space
  mapping(string => uint256) private ownerBySpaceId;
  bool[] spacesStatus;

  //**** Events
  event OwnerRegistered(string _ownerName, address _ownerAccount, uint256 _ownerId);
  event SpaceAdded(string _spaceName, uint256 _ownerId, string _locationAddress, uint _price, address _ownerAccount);
  event DriverAdded(string _driverName, address _driverAccount);
  event CarAdded(string _carId, uint256 _driverId);
  event ReservationCreated(string _spaceName, uint256 reserveId);

  ParkingReservationManager private reservationMgr;

  constructor()  {
      reservationMgr = new ParkingReservationManager();
  }

  function addParkingSpaceOwner(string memory _ownerName, address _spaceOwnerAccount) public returns (uint256){

    uint256 ownerId = ownerIdByName[_ownerName];
    if(!enrolledOwners[ownerId]){// Is a new Owner
      ownersIndex.increment();
      ownerId = ownersIndex.current();

      ownerIdByName[_ownerName] = ownerId;
      ownersById[ownerId] = ParkingSpaceOwner({
                                        id: ownerId,
                                        name: _ownerName,
                                        account: _spaceOwnerAccount
                                    });
      enrolledOwners[ownerId] = true;
      spaceOwners.push(ownersById[ownerId]);
    }
    emit OwnerRegistered(_ownerName, _spaceOwnerAccount, ownerId);
    return ownerId;
  }

  function isOwnerEnrolled(string memory _ownerName) public view returns (bool){

    uint256 ownerId = ownerIdByName[_ownerName];
    return enrolledOwners[ownerId];
  }

  function getOwnersQuantity() public view returns (uint256){
    return ownersIndex.current();
  }
  
  function getSpaceOwnerInfo(uint256 _ownerId) public view returns (string memory name, address account){
   
    return (ownersById[_ownerId - 1].name, ownersById[_ownerId - 1].account);
  }
  function addParkingSpace(string memory _spaceName, uint256 _ownerId, string memory _locationAddress, uint _price) public EnrolledOwner(_ownerId) NonExistentParkingSpace(_spaceName) CorrectSpacePublicationAmount payable {
    
    //Adds a new Parking Space
    spaces.push(ParkingSpace({
                              name: _spaceName,
                              locationAddress: _locationAddress,
                              ownerId: _ownerId,
                              price: _price,
                              isReserved: false 
                            })
               );
    parkingSpaces[_spaceName] = spaceCount.current();
    spacesStatus.push(false);
    spaceCount.increment();

    registeredSpaces[_spaceName] = true;
    ownerBySpaceId[_spaceName] = _ownerId;

    // Take the publication fee
    (bool sent, ) = address(owner()).call{value: msg.value}("");
    require(sent, "Transaction Failed");

    ParkingSpaceOwner memory spaceOwner = ownersById[_ownerId];

    emit SpaceAdded(_spaceName, _ownerId, _locationAddress, _price, spaceOwner.account);
  }

  function getSpacesQuantity() public view returns (uint256){
    return spaceCount.current();
  }

  function getParkingSpaceInfo(uint256 _index) public view returns (string memory name, 
                                                                string memory locationAddress, 
                                                                uint price, 
                                                                bool isReserved, 
                                                                uint256 ownerId, 
                                                                string memory ownerAccount) {

    ParkingSpace memory space = spaces[_index];
    address account = ownersById[space.ownerId].account;                                                                  

    return (space.name,
            space.locationAddress,
            space.price,
            space.isReserved,
            space.ownerId,
            toString(abi.encodePacked(account))
           );
  }

  function getSpacesStatus() public view returns (bool[] memory) {

    return spacesStatus;
  }

  function addDriver(string memory _driverName, address _driverAccount) public NotEnrolledDriver(_driverName) CorrectEnrollmentAmount payable {

    // Increments drivers index an gets the current id
    driversIndex.increment();
    uint256 driverId = driversIndex.current();
    
    driverIdByName[_driverName] = driverId;
    
    driversById[driverId] = Driver({
                                      id: driverId,
                                      name: _driverName,
                                      account: _driverAccount
                                  });
    enrolledDrivers[driverId] = true;

    // Take the driver enrollment fee
    (bool sent, ) = address(owner()).call{value: msg.value}("");
    require(sent, "Transaction Failed");    

    emit DriverAdded(_driverName, _driverAccount);
    
  }

  function addCar(string memory _carId, uint256 _driverId) public EnrolledDriver(_driverId){
    
    carsToDriver[_carId] = _driverId;

    emit CarAdded(_carId, _driverId);

  }

   
  function reserveParkingSpace(string memory _spaceName) public payable {

      // find a parkingSpace with _spaceName
      require(registeredSpaces[_spaceName], "There is no a Parking Space with the specified name.");

      // mark the space as busy
      spaces[parkingSpaces[_spaceName]].isReserved = true;

      // Owner id
      uint256 ownerId = spaces[parkingSpaces[_spaceName]].ownerId;

      // find the space owner
      ParkingSpaceOwner  memory spaceOwner = ownersById[ownerId];

      // create a rervation
      uint256 reservationId =  reservationMgr.reserveParkingSpace(_spaceName, spaceOwner.account, msg.sender);

      // get the reservation fee
      (bool sent, ) = address(owner()).call{value: msg.value}("");
      require(sent, "Transaction Failed");   

      emit ReservationCreated(_spaceName, reservationId);
  }

  function toString(address account) private pure returns(string memory) {
      return toString(abi.encodePacked(account));
  }

  function toString(uint256 value) private pure returns(string memory) {
      return toString(abi.encodePacked(value));
  }

  function toString(bytes32 value) private pure returns(string memory) {
      return toString(abi.encodePacked(value));
  }

  function toString(bytes memory data) private pure returns(string memory) {
      bytes memory alphabet = "0123456789abcdef";

      bytes memory str = new bytes(2 + data.length * 2);
      str[0] = "0";
      str[1] = "x";
      for (uint i = 0; i < data.length; i++) {
          str[2+i*2] = alphabet[uint(uint8(data[i] >> 4))];
          str[3+i*2] = alphabet[uint(uint8(data[i] & 0x0f))];
      }
      return string(str);
  }

}
