# Contract security measures

## SWC-103 (Floating pragma)

Specific compiler pragma `0.8.4` used in contracts to avoid accidental bug inclusion through outdated compiler versions.
Contracts should be deployed with the same compiler version and flags that they have been tested with. Locking the pragma helps ensure that contracts do not accidentally get deployed using the latest compiler which may have higher risks of undiscovered bugs.

## SWC-105 (Unprotected Ether Withdrawal)

`ParkingReservationManager` in `reserveParkingSpace` is protected with OpenZeppelin `Ownable`'s `onlyOwner` modifier.

## SWC-108 State variable default visibility 
All variables defined in the smart contract have their visibility specified.
#