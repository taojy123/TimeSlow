import Web3 from 'web3'
import contract from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import TslowJson from '../../build/contracts/Tslow.json'

// if (typeof web3 !== 'undefined') {
// 	console.warn(
// 		'Using web3 detected from external source.' +
// 			" If you find that your accounts don't appear or you have 0 MetaCoin," +
// 			" ensure you've configured that source properly." +
// 			' If using MetaMask, see the following link.' +
// 			' Feel free to delete this warning. :)' +
// 			' http://truffleframework.com/tutorials/truffle-and-metamask'
// 	)
// 	// Use Mist/MetaMask's provider
// 	window.web3 = new Web3(window.web3.currentProvider)
// } else {
// 	console.warn(
// 		'No web3 detected. Falling back to http://127.0.0.1:7545.' +
// 			" You should remove this fallback when you deploy live, as it's inherently insecure." +
// 			' Consider switching to Metamask for development.' +
// 			' More info here: http://truffleframework.com/tutorials/truffle-and-metamask'
// 	)
// 	// fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
// 	window.web3 = new Web3(
// 		new Web3.providers.HttpProvider('http://127.0.0.1:7545')
// 	)
// }

// const web3 = new Web3(Web3.givenProvider || 'http://localhost:7545')
const web3 = new Web3('http://localhost:7545')

// MetaCoin is our usable abstraction, which we'll use through the code below.
const Tslow = contract(TslowJson)

Tslow.setProvider(web3.currentProvider)
Tslow.deployed()

export { Tslow }
