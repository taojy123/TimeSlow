<template>
  <div>
    <h1>{{ nickname || address }}</h1>
    <p>{{ address }}</p>
    <p>Level: {{ level }}</p>
    <p>Points: {{ points }}</p>
  </div>
</template>

<script>
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'
import TslowJson from '../../../build/contracts/Tslow.json'
import moment from 'moment'

moment.locale('zh-cn')

export default {
  components: {},
  data() {
    return {
      address: this.$route.params.address,
      nickname: '',
      points: 0,
      level: 0,
      web3: null,
      accounts: [],
      tslow: null
    }
  },
  computed: {
    account() {
      return this.accounts[0]
    }
  },
  mounted() {
    this.initContract()
  },
  methods: {
    initContract() {
      if (window.web3) {
        console.log('Use MetaMask')
        this.web3 = new Web3(window.web3.currentProvider)
      } else {
        console.log('Use Ganache')
        this.web3 = new Web3(
          new Web3.providers.HttpProvider('http://127.0.0.1:7545')
        )
      }
      this.accounts = this.web3.eth.accounts
      console.log('accounts:', this.accounts)
      if (!this.accounts) {
        console.error('accounts is empty, please check!')
        return
      }
      const Tslow = contract(TslowJson)
      Tslow.setProvider(this.web3.currentProvider)
      Tslow.deployed().then(tslow => {
        console.log('deployed success:', tslow)
        this.tslow = tslow
        this.loadData()
      })
    },
    loadData() {
      this.tslow.pointsOf(this.address).then(points => {
        this.points = parseInt(points)
      })
      this.tslow.levelOf(this.address).then(level => {
        this.level = parseInt(level)
      })
      this.tslow.nicknameOf(this.address).then(nickname => {
        this.nickname = nickname
      })
    }
  }
}
</script>

<style>
</style>
