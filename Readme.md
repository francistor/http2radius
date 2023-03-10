# Http2radius

Tool that receives http(s)/json requests and produces radius requests to the specified remote server, and back

# Request format

See example below

* `destination` of the form `ip-address:port`
* `packet` Includes the `Code` and the radius AVPs, of the form `VendorName-AttributeName`
* `secret`
* `perRequestTimeoutSpec` number plus `s` for seconds or `ms` for milliseconds
* `tries` number of tries to different servers. Must always be 1
* `serverTries` number of tries to the same server

```json
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
```

## Quickstart

Requres Go 1.18 or higher

```bash
# Generate the executable
git clone https://github.com/francistor/http2radius.git
go build

# Launch
http2radius/http2radius &

# Test by sending a http request that will be sent to http2radius acting as an "echo" server
# perRequestTimeoutSpec is a number followed by "s" or "ms" (seconds or milliseconds)
# serverTries is the number of tries to the specified server, keeping the request id
# tries is the number of tries, where the request id will change. The full number of
# tries will be tries*serverTries.
curl -s http://localhost:8080/routeRadiusRequest -X POST -d '
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

```

Prometheus metrics are exported in a `/metrics` endopoint, by default in port 9090

You an also use
```
./test.sh
```

### What is happening in test mode

We are sending a http POST request to `http2radius`, that will generate a radius packet to `127.0.0.1`. There, a simple radius server
is listening, with a policy that echoes back all packets received. The radius response is mapped again to a JSON object,
that will be received by the http client (e.g. Postman). The Code 2 below is an Access-Accept. The authenticator has been trimmed
for readability, and in reality it is 16 bytes.

```json
{
    "Code": 2,
    "Identifier": 1,
    "Authenticator": [
        245
    ],
    "AVPs": [
        {"User-Name": "MyUserName"},
        {"User-Password": "a very secret password!"},
        {"Tunnel-Server-Endpoint": "10.10.10.10:1"},
        {"Tunnel-Password": "the password for the tunnel:1"},
        {"Cisco-AVPair": "subscriber:sa=internet(shape-rate=1000)"}
    ]
}
```

## Configuration

### Basic

#### Listening ports

Use the following environment variables
* `IGOR_HTTP_PORT` The default is 8080
* `IGOR_METRICS_PORT` The default is 9090
* `IGOR_AUTH_PORT` the default is 1812
* `IGOR_ACCT_PORT` the default is 1813

#### Use https
By default, http is used. To use http, set the environment variable IGOR_USE_PLAINHTTP=false, or change the `httpRouter.json` configuration
file accordingly

### Advanced

There is a number of files in the `resources` directory

* `diamterServer.json` should be always left as it is
* `httpRouter.json` may be used to change the http listening port and whether to use https
* `log.json` is in `uber/zap` format. Use it to change the log level or the location of the logs instead of the standard output
* `metrics.json` to change the metrics export port
* `radiusServer.json` to change the radius listen ports (mainly used for testing only)
* `radiusServers.json` should be left as it is
* `searchRules.json` should be left as it is

You may change the contents of `dictionary` and the files inside `freeradius_dictionaries` to add or change radius attributes definitions

## Running in Docker

The image is published as `francistor/http2radius:<tag>`

Launch attached with to the terminal, with removal on exit, with

```bash
docker run --name http2radius --rm -it -p 1812:1812 -p 1813:1813 -p 8080:8080 francistor/http2radius:0.2
``` 

Or detached

```
docker run --name http2radius -p 1812:1812 -p 1813:1813 -p 8080:8080 -d francistor/http2radius:0.2
```

Change the listening port for http

```
docker run --rm -it --name http2radius -p 1812:1812 -p 1813:1813 -p 8081:8081 -e IGOR_HTTP_PORT=8081 francistor/http2radius:0.2
```

For customization of the configuration, you may mount a volume with the configuration files (that includes the dictionaries)

```
docker run --rm -it -p 1812:1812 -p 1813:1813 -p 8080:8080 -v <http2radius-location>/resources:/http2radius/resources --name http2radius francistor/http2radius:0.2
```





