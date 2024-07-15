// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp()

// Take the text parameter passed to this HTTP endpoint and insert it into
// Firestore under the path /messages/:documentId/original
exports.addmessage = onRequest(async (req, res) => {
    // Grab the text parameter.
    const original = req.query.text;

    // Push the new message into Firestore using the Firebase Admin SDK.
    const writeResult = await getFirestore()
        .collection("messages")
        .add({original: original});
    // Send back a message that we've successfully written the message
    res.json({result: `Message with ID: ${writeResult.id} added.`});
});

exports.createPost = onDocumentCreated("users/{userId}/posts", (event) => {
    const snapshot = event.data
    if (!snapshot) {
        console.log("failed TO detect post snapShot")
        return;
    }
    const data = snapshot.data();
    
});

exports.createuser = onDocumentCreated("users/{userId}", (event) => {
    // Get an object representing the document
    // e.g. {'name': 'Marie', 'age': 66}
    const snapshot = event.data;
    if (!snapshot) {
        console.log("No data associated with the event");
        return;
    }
    const data = snapshot.data();

    // access a particular field as you would any JS property
    // const name = data.name;
});
// execute authentication using firebase and update the state
// export const loginUser = ({ email, password }) => {
//     return (dispatch) => {
//       // dispatch action
//       dispatch({ type: LOGIN_USER });

//       firebase.auth().signInWithEmailAndPassword(email, password)
//       .then(user => loginUserSuccess(dispatch, user))
//       .catch(error => {
//         console.log(error);
//         console.log('creating a new user account...');
//         firebase.auth().createUserWithEmailAndPassword(email, password)
//         .then(user => {
//           // login
//           loginUserSuccess(dispatch, user);
//           //// reigster the user in the database
//           // request permission from the user
//           firebase.messaging().requestPermission();
//           console.log('got the permission');
//           // get the device's push token
//           firebase.messaging().getToken()
//             .then(token => {
//               const { currentUser } = firebase.auth();
//               console.log('currentUserId', currentUser.uid);
//               // store token in the user's document
//               firebase.firestore().collection('users').doc(currentUser.uid)
//                 .set({ pushToken: token, numHelps: 0, numAsks: 0, region: 'suwon' });
//           });
//         })
//         .catch(() => {
//           console.log(error);
//           loginUserFail(dispatch);
//         });
//       });
//     };
//   };

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
