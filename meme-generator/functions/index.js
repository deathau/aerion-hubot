// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database. 
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const storage = admin.app().storage("gs://aerion-hubot-brain.appspot.com");

// The caption SDK to caption images
const caption = require('caption');

// Need these to access filesystem
const path = require('path');
const os = require('os');
const fs = require('fs');

// Take the text parameter passed to this HTTP endpoint and insert it into the
// Realtime Database under the path /messages/:pushId/original
exports.addMessage = functions.https.onRequest((req, res) => {
    // Grab the text parameter.
    const original = req.query.text;
    // Push the new message into the Realtime Database using the Firebase Admin SDK.
    admin.database().ref('/messages').push({original: original}).then(snapshot => {
        // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
        res.redirect(303, snapshot.ref);
        return;
    }).catch(err => {
        console.log(err);
    });
});

// Meme generation function
exports.generateMeme = functions.https.onRequest((req, res) => {
    // Grab the image url, top and bottom text
    const {url, top, bottom} = req.query;
    const options = {
        caption: top || null,
        bottomCaption: bottom || null
    };

    if(url) {
        caption.url(url, options, (err,captionedImage) => {
            if(err) {
                console.log(err);
                return;
            }
            // err will contain an Error object if there was an error
            // otherwise, captionedImage will be a path to a file.
            console.log('Captioned image created at', captionedImage);

            /*
            const storageRef = storage.ref();
            const imageRef = storageRef.child(`memegen/${path.basename(captionedImage)}`);
            imageRef.put


            // We add a 'thumb_' prefix to thumbnails file name. That's where we'll upload the thumbnail.
            const thumbFileName = `thumb_${fileName}`;
            const thumbFilePath = path.join(path.dirname(filePath), thumbFileName);
            // Uploading the thumbnail.
            bucket.upload(tempFilePath, { destination: thumbFilePath, metadata: metadata }).then(() => {
                // Once the thumbnail has been uploaded delete the local file to free up disk space.
                fs.unlinkSync(tempFilePath);
            });
            */

            // Push the result into the Realtime Database using the Firebase Admin SDK.
            admin.database().ref('/memegen').push({captionedImage: captionedImage}).then(snapshot => {
                // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
                res.redirect(303, snapshot.ref);
                return;
            }).catch(err => {
                console.log(err);
            });
        });
    }
});
