// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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

  modifier CorrectSpacePublicationAmount() {
    require(msg.value == spacePublicationFee, "The value must be equal to the space publication fee.");
    _;
  }

  modifier CorrectReservationAmount() {
    require(msg.value == reservationFee, "The value must be equal to the reservation fee.");
    _;
  }

  modifier ReservedParkingSpace(string memory _spaceName) {
    require(spaces[parkingSpaces[_spaceName]].isReserved, "This parking space is not reserved.");
    _;
  }

  uint private constant enrollmentFee = 5;
  uint private constant spacePublicationFee = 4; 
  uint private constant reservationFee = 1;


  ///**** Owners
  ParkingSpaceOwner[] private spaceOwners;
  //To create owner Ids
  using Counters for Counters.Counter;
    Counters.Counter private ownersIndex;
  //Owners by Id. Key: owner Id, Value: ParkingSpaceOwner
  mapping(uint256 => ParkingSpaceOwner) private ownersById;  
  //Owner name to Id
  mapping(string => uint256) ownerIdByName;
  //Allows to know if a owner is already enrolled. Key: owner Id, Value: indicates if the owner is enrolled or not 
  mapping(uint256 => bool) private enrolledOwners;

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

  //Reservation
  mapping(string => uint256) private activeReservation;

  //**** Events
  event OwnerRegistered(string _ownerName, address _ownerAccount, uint256 _ownerId);
  event SpaceAdded(string _spaceName, uint256 _ownerId, string _locationAddress, uint _price, address _ownerAccount);
  event ReservationCreated(string _spaceName, uint256 reserveId);

  ParkingReservationManager private reservationMgr;

  constructor()  {
      reservationMgr = new ParkingReservationManager();
  }

  function addParkingSpaceOwner(string memory _ownerName, address _spaceOwnerAccount) public returns (uint256) {

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
  function addParkingSpace(string memory _spaceName, string memory _locationAddress, uint _price) public NonExistentParkingSpace(_spaceName) CorrectSpacePublicationAmount payable {
    address ownerAccount = msg.sender;
    string memory ownerName = toString(ownerAccount);
    uint256 ownerId = ownerIdByName[ownerName];

    if(!enrolledOwners[ownerId]){

      ownerId = addParkingSpaceOwner(ownerName, ownerAccount);
    }
    
    //Adds a new Parking Space
    spaces.push(ParkingSpace({
                              name: _spaceName,
                              locationAddress: _locationAddress,
                              ownerId: ownerId,
                              price: _price,
                              isReserved: false 
                            })
               );
    parkingSpaces[_spaceName] = spaceCount.current();
    spaceCount.increment();

    registeredSpaces[_spaceName] = true;
    ownerBySpaceId[_spaceName] = ownerId;

    // Take the publication fee
    (bool sent, ) = address(owner()).call{value: msg.value}("");
    require(sent, "Transaction Failed");

    ParkingSpaceOwner memory spaceOwner = ownersById[ownerId];

    emit SpaceAdded(_spaceName, ownerId, _locationAddress, _price, spaceOwner.account);
  }

  function getSpacesQuantity() public view returns (uint256){
    return spaceCount.current();
  }

  function getParkingSpaceInfo(uint256 _index) public view returns (string memory name, 
                                                                string memory locationAddress, 
                                                                uint price, 
                                                                bool isReserved, 
                                                                uint256 ownerId, 
                                                                address ownerAccount) {

    ParkingSpace memory space = spaces[_index];
    address account = ownersById[space.ownerId].account;                                                                  

    return (space.name,
            space.locationAddress,
            space.price,
            space.isReserved,
            space.ownerId,
            account
           );
  }

  function getParkingSpaceInfoByName(string memory _spaceName) public view returns (string memory name, 
                                                                string memory locationAddress, 
                                                                uint price, 
                                                                bool isReserved, 
                                                                uint256 ownerId, 
                                                                address ownerAccount) {
    return getParkingSpaceInfo(parkingSpaces[_spaceName]);                                                                
  }

  function getSpacesStatus() public view returns (bool[] memory) {
    bool[] memory spacesStatus;

    for(uint i = 0; i < spaceCount.current() ; i++){

      spacesStatus[i] = spaces[i].isReserved;
    }
    return spacesStatus;
  }

  function isAReservedSpace(string memory _spaceName) public view returns (bool) {

    return spaces[parkingSpaces[_spaceName]].isReserved;
  }
   
  function reserveParkingSpace(string memory _spaceName) public payable {

    bool sent;

      // find a parkingSpace with _spaceName
      require(registeredSpaces[_spaceName], "There is no a Parking Space with the specified name.");

      // Owner id
      uint256 ownerId = spaces[parkingSpaces[_spaceName]].ownerId;
      // find the space owner
      ParkingSpaceOwner  memory spaceOwner = ownersById[ownerId];

      // create a rervation
      uint256 reservationId =  reservationMgr.reserveParkingSpace(_spaceName, 
                                                                  spaceOwner.account, 
                                                                  msg.sender, 
                                                                  spaces[parkingSpaces[_spaceName]].price
                                                                 );

      // get the reservation fee
      (sent, ) = address(owner()).call{value: reservationFee}("");
      require(sent, "Fee Payment - Transaction Failed");   

      // mark the space as busy
      spaces[parkingSpaces[_spaceName]].isReserved = true;      
      // save de reservation Id
      activeReservation[_spaceName] = reservationId;

      emit ReservationCreated(_spaceName, reservationId);
  }

  function finishParking(string memory _spaceName) public payable ReservedParkingSpace(_spaceName) {

      bool sent;
      address ownerAccount;
      address driverAccount;
      uint256 parkingValue;

      uint256 reservationId = activeReservation[_spaceName];

      // Gets reservationInfo
      ( , ownerAccount, driverAccount, , parkingValue) = reservationMgr.getParkingReservationInfo(reservationId);

      // Validates sender is the reservation driver
      require(driverAccount == msg.sender, "Driver only can finish his own rereservations");

      // Charges the parking cost to the driver and gives to the space owner
      (sent, ) = ownerAccount.call{value: parkingValue}("");
      require(sent, "Parking Cost Payment - Transaction Failed"); 

      // Finishes the reservation
      reservationMgr.finishParking(reservationId);

      // mark the space as free
      spaces[parkingSpaces[_spaceName]].isReserved = false;

      // clear reservationId for current space
      activeReservation[_spaceName] = 0;

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
