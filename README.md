# InterSystems IRIS for Health FHIR

Basic setup of FHIR server using InterSystems IRIS for Health.

**Version:** _containers.intersystems.com/intersystems/irishealth-community:2022.2.0.281.0_

**Make sure you have Docker up and running before starting.**

## Setup

**Make sure you have Docker up and running before starting.**

Clone the repo `git clone https://github.com/OneLastTry/irishealth-fhir.git` and then execute from the main directory `docker-compose build`.

## Execution

Once the build is complete, from the main directory, start your iris container:

- **start container:** `docker-compose up -d`

## Run your Container

After building the image you can simply execute below and you be up and running 🚀:

*-d will run the container detached of your command line session*

```bash
docker-compose up -d
```

You can now access the manager portal through <http://localhost:9092/csp/sys/%25CSP.Portal.Home.zen>

- **Username:** SuperUser
- **Password:** SYS
- **SuperServer port:** 9091
- **Web port:** 9092

To start a terminal session execute:

```bash
docker exec -it iris-fhir iris session iris
```

To start a bash session execute:

```bash
docker exec -it iris-fhir /bin/bash
```

## Stop your Container

```bash
docker-compose stop
```

## Validate your Container

To validate your container simply run `curl http://localhost:9092/demo/fhir/r4/metadata` from your terminal or access the URL from the browser or applications like Postman.

A [Postman project](/IRIS-FHIR.postman_collection.json) is provided with a couple of sample calls.
