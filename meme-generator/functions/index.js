// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database. 
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const storage = admin.app().storage("gs://aerion-hubot-brain.appspot.com");

// spawn child process
const spawn = require('child-process-promise').spawn;

// The caption SDK to caption images
const caption = require('caption');

// Need these to access filesystem
const path = require('path');
const os = require('os');
const fs = require('fs');

// captioned image min height / width
var minHeight = process.env.CAPTION_MIN_HEIGHT || 100
var minWidth = process.env.CAPTION_MIN_WIDTH || 500

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
        const fileName = 'Futurama-Fry.jpg';
        const bucket = storage.bucket();
        const file = bucket.file(fileName);
        const tempFilePath = path.join(os.tmpdir(), fileName);
        const tempFilePathTop = tempFilePath + "-top.jpg";
        const tempFilePathBottom = tempFilePath + "-meme.jpg";

        // default args for imagemagick
        var baseArgs = [
            '-strokewidth','2',
            '-stroke','black',
            '-background','transparent',
            '-fill','white',
            '-gravity','center'
            ];
        var h = minHeight;
        var w = minWidth;

        var topArgs = [...baseArgs,
            `caption:"${unescape(top)}"`,
            tempFilePath,
            '+swap',
            '-gravity','north',
            '-composite',tempFilePathTop
        ];
        var bottomArgs = [...baseArgs,
            `caption:"${unescape(bottom)}"`,
            tempFilePathTop,
            '+swap',
            '-gravity','south',
            '-composite',tempFilePathBottom
        ];

        file.download({
            destination: tempFilePath
        }).then(() => {
            console.log('Image downloaded locally to', tempFilePath);

            return spawn('identify', ['-verbose', tempFilePath], { capture: [ 'stdout', 'stderr' ]});
        }).then(result => {
            const features = imageMagickOutputToObject(result.stdout);

            h = features && features.height < minHeight ? features.height : minHeight
            w = features && features.width < minWidth ? features.width : minWidth;

            var args = [...topArgs,
                '-size',w+'x'+h,
                '-size',w+'x',];

            console.log('running imagemagick with args: %s', args.join(' '))

            return spawn('convert', args);
        }).then(() => {
            var args = [...bottomArgs,
                '-size',w+'x'+h,
                '-size',w+'x',];

            console.log('running imagemagick with args: %s', args.join(' '))

            return spawn('convert', args);
        }).then(() => {
            console.log('Meme image created at', tempFilePathBottom);
            const memeFileName = `meme_${fileName}`;
            return bucket.upload(tempFilePathBottom, { destination: memeFileName });
        }).then(() => {
            fs.unlinkSync(tempFilePath);
            fs.unlinkSync(tempFilePathTop);
            fs.unlinkSync(tempFilePathBottom);

            return;
        }).catch(err => {
            console.log(err);
        });
    }
});

/**
 * Convert the output of ImageMagick's `identify -verbose` command to a JavaScript Object.
 */
function imageMagickOutputToObject(output) {
    let previousLineIndent = 0;
    const lines = output.match(/[^\r\n]+/g);
    lines.shift(); // Remove First line
    lines.forEach((line, index) => {
      const currentIdent = line.search(/\S/);
      line = line.trim();
      if (line.endsWith(':')) {
        lines[index] = makeKeyFirebaseCompatible(`"${line.replace(':', '":{')}`);
      } else {
        const split = line.replace('"', '\\"').split(': ');
        split[0] = makeKeyFirebaseCompatible(split[0]);
        lines[index] = `"${split.join('":"')}",`;
      }
      if (currentIdent < previousLineIndent) {
        lines[index - 1] = lines[index - 1].substring(0, lines[index - 1].length - 1);
        lines[index] = new Array(1 + (previousLineIndent - currentIdent) / 2).join('}') + ',' + lines[index];
      }
      previousLineIndent = currentIdent;
    });
    output = lines.join('');
    output = '{' + output.substring(0, output.length - 1) + '}'; // remove trailing comma.
    output = JSON.parse(output);
    console.log('Metadata extracted from image', output);
    return output;
  }

/**
 * Makes sure the given string does not contain characters that can't be used as Firebase
 * Realtime Database keys such as '.' and replaces them by '*'.
 */
function makeKeyFirebaseCompatible(key) {
    return key.replace(/\./g, '*');
  }
