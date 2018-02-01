// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database. 
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const storage = admin.app().storage("gs://aerion-hubot-brain.appspot.com");

// spawn child process
const spawn = require('child-process-promise').spawn;

// The caption SDK to caption images
const gm = require('gm').subClass({ imageMagick: true });

// Need these to access filesystem
const path = require('path');
const os = require('os');
const fs = require('fs');

// captioned image min height / width
var minHeight = process.env.CAPTION_MIN_HEIGHT || 100
var minWidth = process.env.CAPTION_MIN_WIDTH || 500
var impactFontFound = false;

// Meme generation function
exports.generateMeme = functions.https.onRequest((req, res) => {
    // Grab the image file name, top and bottom text
    let {fileName, top, bottom} = req.query;

    top = unescape(top);
    bottom = unescape(bottom);
    fileName = unescape(fileName);

    impactFontFound = fs.existsSync('impact.ttf');
    console.log(`Found impact.ttf: ${impactFontFound?'YES':'NO'}`)

    if(fileName) {
        // create a hash to identify this meme image
        const hash = hashCode(`top:${top};bottom:${bottom};fileName:${fileName}`);
        
        // get the template image specified from storage
        const bucket = storage.bucket();
        const file = bucket.file(fileName);

        // create a filename to save the result to eventually
        const memeFileName = `memes/${hash}.jpg`;

        // create temp file paths for every step of the process
        let tempFilePath = path.join(os.tmpdir(), `${hash}.jpg`);
        let tempFilePathTop = path.join(os.tmpdir(), `${hash}_top.jpg`);
        let tempFilePathBottom = path.join(os.tmpdir(), `${hash}_final.jpg`);

        // get the default height and width measurement for the text
        let h = minHeight;
        let w = minWidth;

        // a variable to hold the public link when we get there
        let link = null;

        console.log(`attempting to download ${fileName}`);
        // download the file from storage
        file.download({
            destination: tempFilePath
        }).then(() => {
            // image downloaded
            console.log('Image downloaded locally to', tempFilePath);

            return captionImage(top, bottom, tempFilePath, tempFilePathBottom);
        }).then(() => {
            // image created
            console.log('Meme image created at', tempFilePathBottom);
            // return the promise to upload the image to storage
            return bucket.upload(tempFilePathBottom, { destination: memeFileName });
        }).then((uploadResponse) => {
            console.log(uploadResponse);

            // grab the file and its link
            let file = uploadResponse[0];
            link = file.metadata.mediaLink;

            //make the file public
            return file.makePublic();
        }).then((makePublicResponse) =>{
            console.log(makePublicResponse);

            // cleanup
            fs.unlinkSync(tempFilePath);
            fs.unlinkSync(tempFilePathBottom);
            console.log('cleanup successful!');

            // output the uploaded file's name
            res.status(200).send(link);

            // return from this promise
            return true;
        }).catch(err => {
            //log the error
            console.log(err);

            // output the error to the response
            res.status(500).send(JSON.stringify(err));
        });
    }
});

function captionImage(top, bottom, tempFilePath, tempFilePathBottom) {
    return new Promise((resolve, reject) => {
        // get image details so we can work out width, etc.
        const meme = gm(tempFilePath);
        
        meme.size((err, { height }) => {
            if(err) reject(err);
            meme.font('./impact.ttf', 42)
                .fill('white')
                .stroke('black', 2)
                .drawText(0, -(height / 2 - 20), top, 'center')
                .drawText(0, (height / 2 - 20), bottom, 'center')
                .write(tempFilePathBottom, (err) => {
                    if(err) reject(err);
                    else resolve();
                });
        });
    })
}

/**
 * Generates a hash code for a string
 * Taken from https://stackoverflow.com/a/7616484/304786
 */
function hashCode(string) {
    var hash = 0, i, chr;
    if (string.length === 0) return hash;
    for (i = 0; i < string.length; i++) {
        chr   = string.charCodeAt(i);
        hash  = ((hash << 5) - hash) + chr;
        hash |= 0; // Convert to 32bit integer
    }
    return (new Uint32Array([hash]))[0].toString(16); // convert to unsigned and output as a hex string
}

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
