<template>
  <div>
    <h1>Time Slow</h1>
    <p v-for="event in events" :key="event.id">{{ event.title }}</p>
  </div>
</template>

<script>
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'
import TslowJson from '../../build/contracts/Tslow.json'

// // Checking if Web3 has been injected by the browser (Mist/MetaMask)
// if (typeof web3 !== 'undefined') {
// 	console.warn(
// 		'Using web3 detected from external source.' +
// 			" If you find that your accounts don't appear or you have 0 Tslow," +
// 			" ensure you've configured that source properly." +
// 			' If using MetaMask, see the following link.' +
// 			' Feel free to delete this warning. :)' +
// 			' http://truffleframework.com/tutorials/truffle-and-metamask'
// 	)
// 	// Use Mist/MetaMask's provider
// 	window.web3 = new Web3(web3.currentProvider)
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

export default {
	components: {},
	data() {
		return {
			events: [],
			points: 0,
			level: 0,
			nickname: '',
			account: ''
		}
	},
	mounted() {
		const web3 = new Web3(
			new Web3.providers.HttpProvider('http://127.0.0.1:7545')
		)
		web3.eth.getAccounts((err, accs) => {
			if (err != null) {
				alert('There was an error fetching your accounts.')
				return
			}
			if (accs.length === 0) {
				alert(
					"Couldn't get any accounts! Make sure your Ethereum client is configured correctly."
				)
				return
			}
			this.account = accs[0]
			console.log('==================', this.account)

            const Tslow = contract(TslowJson)

			console.log('=============1')
            Tslow.setProvider(web3.currentProvider)
			console.log('=============2', web3.currentProvider)
			Tslow.deployed()
				.then(tslow => {
					console.log('=============3')
					return tslow.getEvents.call()
				})
				.then(events => {
					console.log(events)
					this.events = events
				})
		})
	},
	methods: {}
}
</script>

<style>
</style>
