@echo off
SET FIREBASE_URL=https://aerion-hubot-brain.firebaseio.com
npm install && node_modules\.bin\hubot.cmd --name "hubot" %* 