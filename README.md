## Usage:

Run clamav-rest docker image:
```bash
docker run -p 9000:9000 -e CLAM_USERNAME=username -e CLAM_PASSWORD=password --rm -it karunsiri/clamav-rest
```
where you provide HTTP basic authentication credentials via `CLAM_USERNAME` and
`CLAM_PASSWORD` environment variables.

Test that service detects common test virus signature:
```bash
$ curl -i -u username:password -F "file=@eicar.com.txt" http://localhost:9000/scan
HTTP/1.1 100 Continue

HTTP/1.1 406 Not Acceptable
Content-Type: application/json; charset=utf-8
Date: Mon, 28 Aug 2017 20:22:34 GMT
Content-Length: 56

{ Status: "FOUND", Description: "Eicar-Test-Signature" }
```

Test that service returns 200 for clean file:
```bash
$ curl -i -u username:password -F "file=@clamrest.go" http://localhost:9000/scan

HTTP/1.1 100 Continue

HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Date: Mon, 28 Aug 2017 20:23:16 GMT
Content-Length: 33

{ Status: "OK", Description: "" }
```

where `-u username:password` is the credentials given to an image via
`CLAM_USERNAME` and `CLAM_PASSWORD` environment variables.

**Status codes:**
- 200 - clean file = no KNOWN infections
- 406 - INFECTED
- 400 - ClamAV returned general error for file
- 412 - unable to parse file
- 501 - unknown request


## Developing:

Build golang (linux) binary and docker image:
```bash
env GOOS=linux GOARCH=amd64 go build
docker build . -t <your_username>/clamav-rest
docker run -p 9000:9000 -e CLAM_USERNAME=username -e CLAM_PASSWORD=password --rm -it <your_username>/clamav-rest
```
