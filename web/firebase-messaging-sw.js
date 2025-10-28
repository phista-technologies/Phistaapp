importScripts("https://www.gstatic.com/firebasejs/9.1.3/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.1.3/firebase-messaging-compat.js");

firebase.initializeApp({
     apiKey: "AIzaSyAvMQy6a2ZwU60Yg43NfIhTfz7rZE6bTSY",
     authDomain: "phista-81bf8.firebaseapp.com",
     databaseURL: "https://phista-81bf8-default-rtdb.firebaseio.com",
     projectId: "phista-81bf8",
     storageBucket: "phista-81bf8.firebasestorage.app",
     messagingSenderId: "1058281973456",
     appId: "1:1058281973456:web:fcbb6159d107e5ab06e0d5",
});

const messaging = firebase.messaging();
