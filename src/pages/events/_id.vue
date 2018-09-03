<template>
  <div>
    <h1>{{ title }}</h1>
    <p @click="goToUser(owner)">发布者: {{ ownerNickname }} - {{ display(ts) }}</p>
    <p>{{ content }}</p>

    <div v-for="comment in comments" :key="`comment-${comment.id}`">
      <p>{{ comment.content }}</p>
      <p @click="goToUser(comment.owner)">{{ comment.nickname }} - {{ display(comment.ts) }}</p>
    </div>

    <div>
      <textarea v-model="text" />
      <button @click="postComment">发布评论</button>
    </div>
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
      eventId: this.$route.params.id,
      title: '',
      content: '',
      ts: 0,
      owner: '',
      ownerNickname: '',
      text: '',
      comments: [],
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
      this.text = ''
      this.comments = []
      this.tslow.events(this.eventId).then(r => {
        this.owner = r[1]
        this.title = r[2]
        this.content = r[3]
        this.ts = r[4]
        this.tslow.nicknameOf(this.owner).then(nickname => {
          this.ownerNickname = nickname || this.owner
        })
        this.tslow
          .allEvents({ fromBlock: 0, toBlock: 'latest' })
          .get((err, events) => {
            console.log(err, events)
            for (let e of events) {
              if (
                e.event == 'CommentPosted' &&
                e.args.eventId == this.eventId
              ) {
                this.showCommentByEvent(e)
              }
            }
          })
      })
    },
    showCommentByEvent(event) {
      const id = event.args.id
      const eventId = event.args.eventId
      const owner = event.args.owner
      const content = event.args.content
      const ts = event.args.ts
      this.tslow.nicknameOf(owner).then(nickname => {
        nickname = nickname || owner
        this.comments.push({
          id,
          eventId,
          owner,
          content,
          ts,
          nickname
        })
      })
    },
    display(ts) {
      return moment(ts * 1000).format('LLL')
    },
    postComment() {
      this.tslow
        .postComment(this.eventId, this.text, {
          from: this.account,
          gas: 4612388
        })
        .then(res => {
          console.log('post comment success:', res)
          setTimeout(this.loadData, 1000)
        })
    },
    goToUser(address) {
      this.$router.push('/users/' + address)
    }
  }
}
</script>

<style>
</style>
