# LuizaLabs Employee Manager Challenge Application
[![Build Status](https://travis-ci.org/dutradda/ll-employee-manager.svg?branch=master)](https://travis-ci.org/dutradda/ll-employee-manager) [![Coverage Status](https://coveralls.io/repos/github/dutradda/ll-employee-manager/badge.svg?branch=master)](https://coveralls.io/github/dutradda/ll-employee-manager?branch=master)

## This is a simple application to manage employees.

The application uses a Makefile to support the development and run docker commands.

- Running the tests:

```shell
$ make integration
```

- Serving the application for development:

```shell
$ make dev-server
```

- Only running the `make` command will run the integration and after the dev-server rules.

```shell
$ make
```

- Running the develop environment with a new database:

```shell
$ mv db.sqlite3 db.sqlite3.bkp && \
  make dev-migrate && \
  make dev-superuser && \
  make dev-server
```


### Deploy

- Create the kubernetes deployment (please, configure and install the [kubectl]() properly):

```shell
$ make create-deploy

deployment.apps "employee-manager" created
service "employee-manager" exposed
"Waiting, endpoint for service is not ready yet..."
http://192.168.99.100:31352 # the ip and port can be others

```

- You will need to change the `/etc/hosts` of your machine according to the cluster ip:

```shell
192.168.99.100        employee-manager
```

- You can update the deployment version according to the repository VERSION file:

```shell
$ make update-deploy
```

- Deleting the deployment:

```shell
$ make delete-deploy
```


### Features

 - Private endpoints for `write` access (the users are the same of the django admin)
 - Public endpoints for `read-only` access
 - Email validation


### API Examples

- Adding a new employee (with the default database):
```shell
$ curl -i -H 'Content-Type: application/json' -X POST -u admin:password123 '127.0.0.1:8000/employee' -d '
{
   "name": "Diogo",
   "email": "diogo@luizalabs.com",
   "department": "Architecture"
}'
HTTP/1.1 201 Created
Server: WSGIServer/0.2 CPython/3.7.0b3
Content-Type: application/json
Vary: Accept, Cookie
Allow: GET, POST, HEAD, OPTIONS
X-Frame-Options: SAMEORIGIN
Content-Length: 87

{
  "name": "Diogo",
  "email": "diogo@luizalabs.com",
  "department": "Architecture"
}
```

- Getting the employees:
```shell
$ curl -i '127.0.0.1:8000/employee'
HTTP/1.1 200 OK
Server: WSGIServer/0.2 CPython/3.7.0b3
Content-Type: application/json
Vary: Accept, Cookie
Allow: GET, POST, HEAD, OPTIONS
X-Frame-Options: SAMEORIGIN
Content-Length: 422

[
  {
    "name": "Arnaldo Pereira",
    "email": "arnaldo@luizalabs.com",
    "department": "Architecture"
  },
  {
    "name": "Renato Pedigoni",
    "email": "renato@luizalabs.com",
    "department": "E-commerce"
  },
  {
    "name": "Thiago Catoto",
    "email": "catoto@luizalabs.com",
    "department": "Mobile"
  },
  {
    "name": "Diogo",
    "email": "diogo@luizalabs.com",
    "department": "Architecture"
  }
]
```

- Trying to add an employee without credentials:
```shell
$ curl -i -H 'Content-Type: application/json' -X POST '127.0.0.1:8000/employee' -d '
{
   "name": "Diogo",
   "email": "diogo@luizalabs.com",
   "department": "Architecture"
}'
HTTP/1.1 403 Forbidden
Server: WSGIServer/0.2 CPython/3.7.0b3
Content-Type: application/json
Vary: Accept, Cookie
Allow: GET, POST, HEAD, OPTIONS
X-Frame-Options: SAMEORIGIN
Content-Length: 63

{
  "detail": "Authentication credentials were not provided."
}
```

- Trying to add an employee without a valid email address:
```shell
$ curl -i -H 'Content-Type: application/json' -X POST -u admin:password123 '127.0.0.1:8000/employee' -d '
{
   "name": "Diogo",
   "email": "diogo@luizalabs",
   "department": "Architecture"
}'
HTTP/1.1 400 Bad Request
Server: WSGIServer/0.2 CPython/3.7.0b3
Content-Type: application/json
Vary: Accept, Cookie
Allow: GET, POST, HEAD, OPTIONS
X-Frame-Options: SAMEORIGIN
Content-Length: 48

{
  "email": [
    "Invalid email address"
  ]
}
```

- Removing an employee :(
```shell
$ curl -i -X DELETE -u admin:password123 '127.0.0.1:8000/employee/4'
HTTP/1.1 204 No Content
Server: WSGIServer/0.2 CPython/3.7.0b3
Vary: Accept, Cookie
Allow: GET, PUT, PATCH, DELETE, HEAD, OPTIONS
X-Frame-Options: SAMEORIGIN
Content-Length: 0
```
