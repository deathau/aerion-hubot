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

        file.download({
            destination: tempFilePath
        }).then(() => {
            console.log('Image downloaded locally to', tempFilePath);

            return spawn('identify', ['-verbose', tempFilePath], { capture: [ 'stdout', 'stderr' ]});
        }).then(result => {
            const features = imageMagickOutputToObject(result.stdout);
            console.log(features);

            h = features && features.height < minHeight ? features.height : minHeight
            w = features && features.width < minWidth ? features.width : minWidth;

            var args =  [
                '-font', 'DejaVu-Sans',
                '-strokewidth','2',
                '-stroke','black',
                '-background','transparent',
                '-fill','white',
                '-gravity','center',
                '-size',w+'x'+h,
                'caption:'+unescape(top),
                tempFilePath,
                '+swap',
                '-gravity','north',
                '-size',w+'x',
                '-composite',tempFilePathTop
            ];

            console.log('running imagemagick with args: %s', args.join(' '))

            var promise = spawn('convert', args);

            var childProcess = promise.childProcess;
 
            console.log('[convert] childProcess.pid: ', childProcess.pid);
            childProcess.stdout.on('data', function (data) {
                console.log('[convert] stdout: ', data.toString());
            });
            childProcess.stderr.on('data', function (data) {
                console.log('[convert] stderr: ', data.toString());
            });

            return promise;
        }).then(() => {
            var args =  [
                '-font', 'DejaVu-Sans',
                '-strokewidth','2',
                '-stroke','black',
                '-background','transparent',
                '-fill','white',
                '-gravity','center',
                '-size',w+'x'+h,
                'caption:' + unescape(bottom),
                tempFilePathTop,
                '+swap',
                '-gravity','south',
                '-size',w+'x',
                '-composite',tempFilePathBottom
            ];

            console.log('running imagemagick with args: %s', args.join(' '))

            var promise = spawn('convert', args);

            var childProcess = promise.childProcess;
 
            console.log('[convert] childProcess.pid: ', childProcess.pid);
            childProcess.stdout.on('data', function (data) {
                console.log('[convert] stdout: ', data.toString());
            });
            childProcess.stderr.on('data', function (data) {
                console.log('[convert] stderr: ', data.toString());
            });

            return promise;

        }).then(() => {
            console.log('Meme image created at', tempFilePathBottom);
            const memeFileName = `meme_${fileName}`;
            return bucket.upload(tempFilePathBottom, { destination: memeFileName });
        }).then(() => {
            fs.unlinkSync(tempFilePath);
            fs.unlinkSync(tempFilePathTop);
            fs.unlinkSync(tempFilePathBottom);
            console.log('cleanup successful!');

            return true;
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
    if((!output.width || !output.height) && output.Geometry) {
        // parse the geometry
        var split = output.Geometry.split('x');
        output.width = split[0];
        split = split[1].split('+');
        output.height = split[0];
    }
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
