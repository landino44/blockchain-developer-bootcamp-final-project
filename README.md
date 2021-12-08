# blockchain-developer-bootcamp-final-project
Luciano Andino's final project

## **Rent a Parking Space**
This dapp allows people to rent a parking space per hour. 
Parking lots and individuals can offer their free spaces. Ussing the app, driver will be able to seach into the free spaces close to their destination,  reserve one of them for a period of time, and paying its cost by a direct transfer to the owner.
To simplify the problem, drivers will not be able to make a reservation for a future day. Each reservation must be for at least one hour.


**Parking Space**
Every Parking S

The city is divided into different areas, which are labeled on every street, and each of them has a parking price per hour.

**Government**
The government is the entity that will receive every payment, and it will charge a fine if there is a parked car without initiate its parking time in the app.

**Controller**
Controllers will verify each parked car, try to find if anyone has not been initiated its parking time in the app. If so, the controller will send the information to the government, which charge the driver with a fine.

**Driver**
Drivers has an account where they can deposit credit sending a transference to the Government. Drivers will use that credit to pay their parking time.
Each driver will have a collection of cars, that will be represented just with an id.

## **Attributes and Behavior**
There will be 4 contracts: ParkingArea, Government, Controller, Driver.

**ParkingArea**
    Attributes
    •	government: id of government which it belongs.
    •	id: area name.
    •	price: parking price for an hour. This the only that will be able to change in the future.
    Behavior
    •	Initialization: it will be initialized providing its three attributes. 
    •	setPrice: it allows the Government to change the value of parking time. This method must verify the caller is the Government.
    •	getPrice: it allows everyone to know the price of parking hour in this area. 

**Government**
    Attributes
    •	parkingAreas: a collection of ParkingAreas. To simplify access, it will be a mapp having as key the ParkingArea’s id, and value the instance.
    •	fineValues: a map of fines. Its key will be the ParkingArea’s id, and the value the fine’s amount.
    •	registeredDrivers: a map to indicate if a driver has been registered in the app.
    •	parkedCars: a collection of parked cars. To simplify access, it would be a map.
    Behavior
    •	registerDriver: this function allows to register the sender as a driver, putting its address into the registeredDrivers map. 
    •	

**Controller**
    Attributes

    Behavior
    •	verifyParkedCar: this function verifies if the parked car has initiated its parking time. If not, will send a message to the Government to charge the driver with a fine.

**Driver**
    Attributes
    •	balance: it saves the driver’s credits.
    •	cars: a collection of car’s ids. This is a map, that indicates if each car is parked or not. 
    •	

    Behavior
    •	register: this function registers the driver in the dapp. It sends the registration to the Government. This function must be called for the owner.
    •	addACar: this is to add a car in the cars collection. This function must be called for the owner.
    •	addCredit: this function allows the driver to add credits in his balance. This value will be transferred to the Government. This function must be called for the owner.
    •	starParkingTime: this function allows the driver to park one of his cars, indicating its id by a parameter. This function must be called for the owner.
    •	stopParkingTime: it finishes the parking time, and it will transfer the amount to the Government.


