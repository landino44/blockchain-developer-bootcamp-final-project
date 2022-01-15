# blockchain-developer-bootcamp-final-project
Luciano Andino - Final Project

## **Rent a Parking Space**
This dapp allows people to rent a parking space per day. 
Parking lots and individuals can offer their free spaces. Ussing the app, driver will be able to seach into the free spaces close to their destination,  reserve one of them for a period of time, and pay its cost by a direct transfer to the owner.
To simplify the problem, drivers will not be able to make a reservation for a future day, and each reservation must be for the whole day.
This Dapp will have two smart contracts: ParkingSystem and ParkingReservationManager.
 
**ParkingSystem**
This is the main smart contract. It will allow owners to add their parking spaces paying a registration fee, then drivers will be able to reserve them for a day. When parking finishes, the smart contract will charge its cost and it will transfer it to the owner.

**ParkingReservationManager**
This smart contract is in charge of saving the reservations and control their states.
Note: This smart contract is not strictly necessary, because its behavior could be developed in ParkingSystem; but I've decided to write it just to have interaction between two smart contracts.

## **Attributes and Behavior**
**ParkingSystem**

  Structs
    	•	ParkingSpaceOwner: it represents the owner of parking spaces. It has the account where he will receive his payments for each rent.
    	•	ParkingSpace: it has the information of the parking spaces: location, owner, parking price and its reservation status.
   
  Attributes
    	•	spaceOwners: a collection of ParkingSpaceOwner. 
	•	ownerIndex: it is an id of Owners. It will increment for each owner registered in the system. Note: to implement this, I've used Conters.Counter of "@openzeppelin/contracts/utils/Counters.sol".
	•	ownersById: it is a mapping to find an Owner by its Id.
	•	ownerIdByName: it is a mapping to find the Owner Id by its name.
	•	enrolledOwners: to control enrolled owners.
    	•	parkingSpaces: a mapping to find space Id by its name. 
	•	spaces: a collection of ParkingSpaces.
	•	spaceCount: a count of spaces. Note: to implement this, I've used Conters.Counter of "@openzeppelin/contracts/utils/Counters.sol".
	•	registeredSpaces: to control registered spaces, using its name as unique key.
	•	ownerBySpaceId: a mapping to get the owner Id by space name.	
	•	activeReservation: a mapping to get the reservation Id by space name.
	
    Behavior
    •	addParkingSpaceOwner: to register a new owner. This is used internally, when a space is registered.
    •	isOwnerEnrolled: to know if a specific owner is already enrolled.
    •	getOwnersQuantity: to get owners registered quantity. 
    •	addParkingSpace: to register a new parking space. It will take the sender as the space owner. If the owner is not registered, it will create it and save it. The space registration has a fee (system fee), and it will be charged to the owner.
    •	getSpacesQuantity: to get spaces registered quantity.
    •	getParkingSpaceInfo: to get space information specifying a space index. 
	•	getParkingSpaceInfoByName: to get space information specifying a space name. 
    •	getSpacesStatus: to get statuses of every registered space.
    •	isAReservedSpace: to know if a space is already reserved. 
	•	reserveParkingSpace: to reserve a parking space. It will asume the driver is the sender. This operation has a fee (system fee), and it will be charged to the driver. It controls the driver is not the space owner.
	•	finishParking: to finish a parking in progress. It controls the sender is the same driver who made the reservation, and the its state. At this time the driver will pay the parking price to the owner.

**ParkingReservationManager** 
Note: It implements Ownable of "@openzeppelin/contracts/access/Ownable.sol"
    Structs
    •	Reservation: the information of the reservation: space name, accounts (owner and driver), status and parking price.
	enum
    •	Status: to represent the reservation status: InProgress and Finished.
   
   Attributes
	•	reservationIndex: to create the reservation index. It will increment for each reservation. Note: to implement this, I've used Conters.Counter of "@openzeppelin/contracts/utils/Counters.sol".
	•	reservations: a collection of created reservations.
	
    Behavior
    •	getParkingReservationInfo: to get the information of the reservation.
    •	reserveParkingSpace: to create a reservation. It controls the driver is not the space owner. 
    •	finishParking: to finisha reservation in progress.
