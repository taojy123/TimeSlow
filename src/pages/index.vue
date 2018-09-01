<template>
  <div>
    <h1>Time Slow</h1>
    <p>{{ account }}</p>
    <p>{{ nickname }}</p>
    <p>my level: {{ level }}, points: {{ points }}</p>
    <div v-for="event in events" :key="`event-${event.id}}`" @click="goToEvent(event.id)">
      <p>{{ event.title }}</p>
      <p>{{ event.content }}</p>
      <p>{{ display(event.ts) }}</p>
    </div>
    <div>
      <input v-model="title" type="text">
      <textarea v-model="content" />
      <button @click="postEvent">发布事件</button>
    </div>
    <div>
      <input v-model="nickname" type="text">
      <button @click="setNickname">设置昵称</button>
    </div>
  </div>
</template>

<script>
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'
import TslowJson from '../../build/contracts/Tslow.json'
import moment from 'moment'

moment.locale('zh-cn')

export default {
  components: {},
  data() {
    return {
      events: [],
      points: 0,
      level: 0,
      nickname: '',
      title: '',
      content: '',
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
      this.title = ''
      this.content = ''
      this.tslow.myPoints({ from: this.account }).then(points => {
        this.points = parseInt(points)
      })
      this.tslow.myLevel({ from: this.account }).then(level => {
        this.level = parseInt(level)
      })
      this.tslow.myNickname({ from: this.account }).then(nickname => {
        this.nickname = nickname
      })
      this.tslow.getEventIds().then(ids => {
        this.events = []
        for (let evendId of ids.reverse()) {
          this.tslow.events(evendId).then(r => {
            this.events.push({
              id: r[0],
              owner: r[1],
              title: r[2],
              content: r[3],
              ts: r[4]
            })
          })
        }
      })
    },
    display(ts) {
      return moment(ts * 1000).format('LLL')
    },
    postEvent() {
      this.tslow
        .postEvent(this.title, this.content, {
          from: this.account,
          gas: 4612388
        })
        .then(res => {
          console.log('post event success:', res)
          setTimeout(this.loadData, 1000)
        })
    },
    setNickname() {
      this.tslow
        .setNickname(this.nickname, {
          from: this.account,
          gas: 4612388
        })
        .then(res => {
          console.log('set nickname success:', res)
        })
    },
    goToEvent(eventId) {
      this.$router.push('/events/' + eventId)
    }
  }
}
</script>

<style>
</style>
