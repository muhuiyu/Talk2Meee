const express = require('express')
const app = express()
const server = require('http').Server(app)
const io = require('socket.io')(server)
const { randomUUID } = require('crypto')
const { initializeApp } = require('firebase/app')
const { getFirestore } = require('firebase/firestore/lite')
const { onSnapshot, collection, updateDoc, doc } = require('firebase/firestore')

const firebaseConfig = {
  apiKey: 'AIzaSyAwsjMIdLD-9yRr9_3EVzusPSllphbjCVQ',
  authDomain: 'hey-there-muyuuu.firebaseapp.com',
  databaseURL: 'https://hey-there-muyuuu-default-rtdb.asia-southeast1.firebasedatabase.app',
  projectId: 'hey-there-muyuuu',
  storageBucket: 'hey-there-muyuuu.appspot.com',
  messagingSenderId: '749829486080',
  appId: '1:749829486080:web:d4d4a88ca6d4c956c24ae5',
  measurementId: 'G-QC2LF1DE4X',
}

// Initialize Firebase
const firebaseapp = initializeApp(firebaseConfig)
const db = getFirestore(firebaseapp)
// async function getUsers(db, callback) {
//   const unsubscribe = onSnapshot(
//     collection(db, 'users'),
//     (snapshot) => {
//       const userList = snapshot.docs.map((doc) => doc.data())
//       console.log('fetched users', userList)
//       callback(userList)
//     },
//     (error) => {
//       console.error('Failed to fetch users: ', error)
//     },
//   )

//   return unsubscribe // Return the unsubscribe function for later use
// }

const sockets = new Map() // key: userID, value: socketID
const users = new Map() // key: socketID, value: userID
const chats = new Map() // key: chatID, value: array of userIDs
const bufferedMessages = new Map() // key: userID, value: array of messages

// message status: sending, sent, seen

io.on('connection', (socket) => {
  let userId = socket.handshake.auth.userId
  console.log('a user connected')
  users.set(socket.id, userId)
  sockets.set(userId, socket.id)

  // user connects chat, send buffered messages to user
  if (bufferedMessages.has(userId)) {
    const messages = bufferedMessages.get(userId)
    messages.forEach((message) => {
      socket.emit('receiveMessage', message)
    })
    bufferedMessages.delete(userId)
  }

  // user subscribes to rooms
  socket.on('subscribe', (chatIds) => {
    chatIds.forEach((chatId) => {
      console.log('user joined chat', chatId)

      let currentUsers = chats.get(chatId)
      if (!currentUsers) {
        // If no current users, initialize an empty array
        currentUsers = []
      }
      // Add the new user to the chat
      const updatedUsers = [...currentUsers, userId]

      chats.set(chatId, updatedUsers)
      socket.join(chatId)
    })
  })

  // send message
  socket.on('sendMessage', (message) => {
    // if user is not subscribed to chat, join chat
    socket.join(message.chatID)
    console.log('received message', message)
    io.to(message.chatID).emit('receiveMessage', message)

    // check all users inside chat, save messages to buffer if user is not online
    const chat = chats.get(message.chatID)
    chat.forEach((userID) => {
      const socketID = sockets.get(userID)
      if (!socketID) {
        // user is not online
        if (!bufferedMessages.has(userID)) {
          bufferedMessages.set(userID, [])
        }
        bufferedMessages.get(userID).push(message)
      }
    })
  })

  // user typing
  socket.on('userTyping', (data) => {
    const { chatID, userID } = data
    socket.emit.to(chatID).emit('userTyping', { userID, chatID })
  })

  // user stopped typing
  socket.on('userStoppedTyping', (data) => {
    const { chatID, userID } = data
    socket.emit.to(chatID).emit('userStoppedTyping', { userID, chatID })
  })

  // user has received message
  socket.on('messageReceived', (data) => {
    const { chatID, messageID, userID } = data
    // TODO: save last received and last seen message ID
    // socket.emit.to(chatID).emit('messageReceived', { chatID, messageID, userID })
  })

  // user has seen message
  socket.on('messageSeen', (data) => {
    const { chatID, messageID, userID } = data
    // TODO: save last received and last seen message ID
  })

  // Disconnect
  socket.on('disconnect', () => {
    console.log('user disconnected')
    const userID = users.get(socket.id)
    if (userID) {
      sockets.delete(userID)
    }
    users.delete(socket.id)
  })
})

server.listen(3000, () => {
  console.log('listening on *:3000')
})
