const emptyAddress = "0x0000000000000000000000000000000000000000";
const BN = web3.utils.BN;
const ParkingSystem = artifacts.require("ParkingSystem");

 

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("ParkingSystem", function (accounts ) {
  it("should assert true", async function () {
    
    const parkingSystem = await ParkingSystem.deployed();

    console.log("AGREGA EL OWNER");
    const trx = await parkingSystem.addParkingSpaceOwner( "Owner1", accounts[0] );
    //console.log(trx);
    //console.log(trx.logs[0].args._ownerId.toNumber());
    const ownerId = trx.logs[0].args._ownerId;
    //console.log(ownerId);
    const ownerAccount = trx.logs[0].args._ownerAccount;
    console.log("CUENTA DEL OWNER: ");
    console.log(ownerAccount);
    //const isEnrolled = parkingSystem.isOwnerEnrolled("Owner1");
    //console.log(isEnrolled);
    console.log("AGREGA EL ESTACIONAMIENTO");
    const trx2 = await parkingSystem.addParkingSpace("ParkingSpace1", ownerId, "Pueyrredón y Guido", 15, {value: 4});
    console.log("CUENTA DEL ORDEN USADA EN EL ESTACIONAMIENTO: ");
    console.log(trx2.logs[0].args._ownerAccount);
    //await parkingSystem.reserveParkingSpace("ParkingSpace1"); 
    console.log("PIDE DATOS DE LOS ESTACIONAMIENTOS");
    const result = await parkingSystem.getParkingSpaceInfo(0);
    console.log("RESULTADO DE LA BÚSQUEDA: ");
    console.log(result[0]);
    console.log(result[1]);
    console.log(result[2].toNumber());
    console.log(result[3]);
    console.log(result[4].toNumber());
    console.log(result[5]);


  

    /*
    assert.equal(
      isEnrolled,
      true,
      "Owner1 is not already enrolled.",
    );*/
  });
});
