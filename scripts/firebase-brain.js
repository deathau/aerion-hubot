'use strict'

// Description:
//   Persist hubot's brain to firebase
//
// Configuration:
// FIREBASE_URL: The url of your firebase realtime database
// FIREBASE_SERVICE_ACCOUNT: The contents of the service account private key json file generatied in the firebase admin console (https://console.firebase.google.com/project/_/settings/serviceaccounts/adminsdk)
//
// Commands:
//   None

const firebase = require("firebase-admin");

module.exports = function (robot) {
  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT) : require("./lib/firebaseServiceAccount.json");
  var config = {
    credential: firebase.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_URL,
  };
  firebase.initializeApp(config);

  var db = firebase.database();

  var dbRef = db.ref('hubot');  

  dbRef.on('value', (data) => {
    robot.logger.info(`firebase-brain: merging data from firebase`);
    robot.brain.mergeData(data.val());
  });

  robot.logger.info(`firebase-brain: Hi!`);
  robot.brain.emit('connected');

  // when brain is saved
  robot.brain.on('save', (data) => {
    if (!data) {
      data = {}
    }
    // send `${data}` to firebase (replace undefineds with null)
    dbRef.set(JSON.parse(replaceAll(JSON.stringify(data),"undefined","null")));
  });

  // disconnect
  robot.brain.on('close', () => {

  });
}

//to search and replace    
const replaceAll  =(s="",f="",r="")=>  s.replace(new RegExp(f.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'), 'g'), r);
