#!/bin/bash

./http2radius &

# Wait for server to start
sleep 2

# Send request that will be replied echoing all attributes
response=$(curl -s http://localhost:8080/routeRadiusRequest -X POST -d '
{
"destination": "127.0.0.1:1812",
"packet": {
  "Code": 1,
  "AVPs":[
    {"User-Name":"MyUserName"},
    {"User-Password": "a very secret password!"},
    {"Tunnel-Server-Endpoint": "10.10.10.10:1"},
    {"Tunnel-Password": "the password for the tunnel:1"},
    {"Cisco-AVPair": "subscriber:sa=internet(shape-rate=1000)"}
  ]
},
"secret": "secret",
"perRequestTimeoutSpec": "1s",
"tries": 1,
"serverTries": 1
}
')

pkill http2radius

sleep 1
echo "-------------------------------------------------"
echo "RESPONSE"
echo "-------------------------------------------------"
echo $response
echo "-------------------------------------------------"