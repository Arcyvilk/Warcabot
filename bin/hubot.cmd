@echo off

call npm install
SETLOCAL
SET PATH=node_modules\.bin;node_modules\hubot\node_modules\.bin;%PATH%
HUBOT_SLACK_TOKEN=xoxb-199331213890-hCrYLZXpbwEZxzFQnVPkxGVM

node_modules\.bin\hubot.cmd --name "Warcabot" %* 
