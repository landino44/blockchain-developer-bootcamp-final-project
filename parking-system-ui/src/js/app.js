
const network = "HTTP://192.168.1.77:8545";
const enrollmentFee = 5;
const spacePublicationFee = 4; 
const reservationFee = 1;

App = {
  
  web3Provider: null,
  contracts: {},

  init: async function() {

    return  await App.initWeb3();
  },

  initWeb3: async function() {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.request({ method: "eth_requestAccounts" });;
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider(network);
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },


  initContract: function() {
    
    $.getJSON('ParkingSystem.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with @truffle/contract
      var ParkingSystemArtifact = data;
      App.contracts.ParkingSystem = TruffleContract(ParkingSystemArtifact);
    
      // Set the provider for our contract
      App.contracts.ParkingSystem.setProvider(App.web3Provider);
    
      // Use our contract to retrieve and mark the reserved places
      return App.readSpaces();   
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-reserve', App.handleReserve);
    $(document).on('click', '.btn-add-space', App.handleAddSpace);
  },

  updateButtonLabel: function(spaceName) {
    App.contracts.ParkingSystem.deployed().then(function(instance) {
      
      parkingSystemInstance = instance;
      return parkingSystemInstance.getParkingSpaceInfoByName.call(spaceName); 
      
    }).then(function(result) {
      
      var parent = $('.panel-body[data-id="' +  spaceName  + '"]');
      if(result[3]){
        parent.find("button").text("Finish");
      } else {
        parent.find("button").text("Reserve");
      }
      
      
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  readSpaces: function(event) {

    var parkingSystemInstance;
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
      App.contracts.ParkingSystem.deployed().then(function(instance) {
        parkingSystemInstance = instance;
    
        return parkingSystemInstance.getSpacesQuantity.call(); 

      }).then(function(quantity){

        var parkingRow = $('#parkingRow');
        var parkingTemplate = $('#parkingTemplate');
        var imgIdx = 0;

        for (i = 0; i < quantity.toNumber(); i++) {

          parkingSystemInstance.getParkingSpaceInfo.call(i).then(function(info){

            var parent = $('.panel-body-owner[data-id="' +  i  + '"]');

            imgIdx = imgIdx + 1;
            if(imgIdx > 3){
              imgIdx = 1;
            }  
            parkingTemplate.find('.panel-body-space').attr('data-id', info[0]);
            parkingTemplate.find('.panel-title').text(info[0]);
            parkingTemplate.find('img').attr('src', "../images/ParkingSpace" + imgIdx + ".jpg");
            parkingTemplate.find('.parking-location').text(info[1]);
            parkingTemplate.find('.parking-price').text(info[2].toNumber());
            let result = info[5].substring(0, 7) + "..." + info[5].substring(32, 42);
            parkingTemplate.find('.owner-account').text(result);
            parkingTemplate.find('.parking-status').text((info[3])?"Reserved":"Free");
            parkingTemplate.find('.btn-reserve').attr('data-id', info[0]).text(!(info[3])?"Reserve":"Finish");

            parkingRow.append(parkingTemplate.html());
          }).catch(function(err) {
            console.log(err.message);
          });
        }        
        
      })      
    });
  },   

  handleReserve: function(event) {
    event.preventDefault();
    var spaceName = $(event.target).data('id');
    var parkingSystemInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
    
      App.contracts.ParkingSystem.deployed().then(function(instance) {
        parkingSystemInstance = instance;
    
          return parkingSystemInstance.getParkingSpaceInfoByName.call(spaceName); 

      }).then(function(space){
          
        if(space[3]) { // is a reserved space
            var price = space[2].toNumber(); //reservation price
            return parkingSystemInstance.finishParking(spaceName, {from: ethereum.selectedAddress, value: price});
          }
          
          return parkingSystemInstance.reserveParkingSpace(spaceName, {from: ethereum.selectedAddress, value: reservationFee}); 
      }).then(function(result) {

        document.getElementById("parkingRow").innerHTML = "";
        return App.readSpaces();
      }).catch(function(err) {
        console.log(err.message);
        window.alert(getErrorMessage(err.message));
      });
    });
  },

  handleAddSpace: function(event) {
    event.preventDefault();

    var parkingSystemInstance;
    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }
    
      App.contracts.ParkingSystem.deployed().then(function(instance) {
        parkingSystemInstance = instance;
    
        var spaceName = document.getElementById("space-name-input").value;
        var spaceAddress = document.getElementById("space-address-input").value;
        var spacePrice = document.getElementById("space-price-input").value;
        
        return parkingSystemInstance.addParkingSpace(spaceName, spaceAddress, spacePrice,{from: ethereum.selectedAddress,value: spacePublicationFee});
      }).then(function(result) {
        document.getElementById("space-name-input").value = "";
        document.getElementById("space-address-input").value = "";
        document.getElementById("space-price-input").value = "";
        document.getElementById("parkingRow").innerHTML = "";

        return App.readSpaces();
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  }

};

// Detect wallet is already intalled
window.addEventListener('load', function(){
  let mmDetected = document.getElementById('mm-detected')
  if(typeof ethereum !== 'undefined'){
      console.log('Wallet detected')
      mmDetected.innerHTML = "<p style='color:green'> MetaMask has been detected <b/>"
  }
  else {
      console.log('There is no Wallet available')
      mmDetected.innerHTML = "<p style='color:red'> There is no Wallet available <p/>"
      this.alert("You need to install a Wallet")
  }
})

const mmEnabled = document.getElementById('mm-connect');
mmEnabled.onclick = async () => {

  await ethereum.request({
      method: 'eth_requestAccounts'
  })

  const mmCurrectAccount = document.getElementById('mm-current-account');

  mmCurrectAccount.innerHTML = "Current account: " + ethereum.selectedAddress
}

function getErrorMessage(msg) {
  var idx = msg.search("reason");
  if(idx >= 0){
    var res = msg.substring(idx + 9, idx + 100);
    idx = res.search("}");
    if(idx >=0){
      res = res.substring(0, idx - 1);
      return res;
    }
    return res;
  }
  return msg;
}

$(function() {
  $(window).load(function() {
    App.init();
  });
});
