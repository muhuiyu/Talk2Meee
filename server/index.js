const express = require('express')
const app = express()
const server = require('http').Server(app)
const io = require('socket.io')(server)
const { randomUUID } = require('crypto')

const users = new Map()

io.on('connection', (socket) => {
  let userId = socket.handshake.auth.userId
  console.log('a user connected')

  users.set(socket.id, userId)

  io.emit('receiveNewUser', userId, Object.fromEntries(users))

  socket.on('sendMessage', (message) => {
    const userId = users.get(socket.id)
    io.emit('receiveMessage', randomUUID(), userId, message)
  })

  socket.on('disconnect', () => {
    console.log('user disconnected')
    users.delete(socket.id)
  })
})

server.listen(3000, () => {
  console.log('listening on *:3000')
})
