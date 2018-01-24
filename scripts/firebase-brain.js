'use strict'

// Description:
//   Persist hubot's brain to firebase
//
// Configuration:
//
// Commands:
//   None

const firebase = require("firebase-admin");
//const serviceAccount = require("./lib/firebaseServiceAccount.json");

module.exports = function (robot) {
  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  robot.logger.info(`firebase-brain: private key: ${serviceAccount.private_key}`);
  var config = {
    credential: firebase.credential.cert(serviceAccount),
    databaseURL: "https://aerion-hubot-brain.firebaseio.com",
  };
  firebase.initializeApp(config);

  var db = firebase.database();

  var dbRef = db.ref('hubot');  

  dbRef.on('value', (data) => {
    robot.logger.info(`firebase-brain: merging data from firebase`);
    robot.brain.mergeData(data.val());
  });

  /*
  dbRef.on('child_added', function(data) {
    robot.logger.info(`firebase-brain: merging data ${data.key}`);
    robot.brain.mergeData(data);
  });

  dbRef.on('child_changed', function(data) {
    robot.logger.info(`firebase-brain: merging data ${data.key}`);
    robot.brain.mergeData(data);
  });
  
  dbRef.on('child_removed', function(data) {
    robot.logger.info(`firebase-brain: merging data ${data.key}`);
    robot.brain.mergeData(data);
  });
  */
  robot.logger.info(`firebase-brain: Hi!`);
  robot.brain.emit('connected');

  // when brain is saved
  robot.brain.on('save', (data) => {
    if (!data) {
      data = {}
    }
    // send `${data}` to firebase
    dbRef.set(JSON.parse(replaceAll(JSON.stringify(data),"undefined","null")));
  });

  // disconnect
  robot.brain.on('close', () => {

  });

  /*
  // turn auto save off until loaded
  robot.brain.setAutoSave(false);

  // log error
  if (err) {
    return robot.logger.error('firebase-brain: Error')
  }

  // log info
  robot.logger.info('firebase-brain: info')

  // code to merge data and then say connected
  robot.brain.mergeData(JSON.parse(reply.toString()))
  robot.brain.emit('connected')

  // turn autosave back on
  robot.brain.setAutoSave(true)

  // when brain is saved
  robot.brain.on('save', (data) => {
    if (!data) {
      data = {}
    }
    // send `${data}` to firebase
  })

  // disconnect
  robot.brain.on('close', () => {

  })
  */
}

//to search and replace    
const replaceAll  =(s="",f="",r="")=>  s.replace(new RegExp(f.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'), 'g'), r);
