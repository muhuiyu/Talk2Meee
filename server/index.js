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

const users = new Map()
const chats = new Map()

io.on('connection', (socket) => {
  let userId = socket.handshake.auth.userId
  console.log('a user connected')
  users.set(socket.id, userId)

  // user subscribes to rooms
  socket.on('subscribe', (chatIds) => {
    chatIds.forEach((chatId) => {
      console.log('user joined chat', chatId)
      socket.join(chatId)
    })
  })

  // send message
  socket.on('sendMessage', (message) => {
    // if user is not subscribed to chat, join chat
    socket.join(message.chatID)
    console.log('received message', message)
    io.to(message.chatID).emit('receiveMessage', message)
  })

  socket.on('disconnect', () => {
    console.log('user disconnected')
    users.delete(socket.id)
  })
})

server.listen(3000, () => {
  console.log('listening on *:3000')
})
