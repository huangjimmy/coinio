# Run in docker

Simple and fast setup of CPS on Docker is also available.

## Install Dependencies
 - [Docker](https://docs.docker.com) Docker 17.05 or higher is required

## Docker Requirement
 - At least 8GB RAM (Docker -> Preferences -> Advanced -> Memory -> 8GB or above)
 
## Build cps image

```bash
git clone https://github.com/CPSIO/cps.git --recursive
cd cps/Docker
docker build . -t cpsio/cps
```

## Start cpsd docker container only

```bash
docker run --name cpsd -p 8888:8888 -p 9876:9876 -t cpsio/cps start_cpsd.sh arg1 arg2
```

By default, all data is persisted in a docker volume. It can be deleted if the data is outdated or corrupted:
``` bash
$ docker inspect --format '{{ range .Mounts }}{{ .Name }} {{ end }}' cpsd
fdc265730a4f697346fa8b078c176e315b959e79365fc9cbd11f090ea0cb5cbc
$ docker volume rm fdc265730a4f697346fa8b078c176e315b959e79365fc9cbd11f090ea0cb5cbc
```

Alternately, you can directly mount host directory into the container
```bash
docker run --name cpsd -v /path-to-data-dir:/opt/cps/bin/data-dir -p 8888:8888 -p 9876:9876 -t cpsio/cps start_cpsd.sh arg1 arg2
```

## Get chain info

```bash
curl http://127.0.0.1:8888/v1/chain/get_info
```

## Start both cpsd and walletd containers

```bash
docker-compose up
```

After `docker-compose up`, two services named cpsd and walletd will be started. cpsd service would expose ports 8888 and 9876 to the host. walletd service does not expose any port to the host, it is only accessible to cpsc when runing cpsc is running inside the walletd container as described in "Execute cpsc commands" section.


### Execute cpsc commands

You can run the `cpsc` commands via a bash alias.

```bash
alias cpsc='docker-compose exec walletd /opt/cps/bin/cpsc -H cpsd'
cpsc get info
cpsc get account inita
```

Upload sample exchange contract

```bash
cpsc set contract exchange contracts/exchange/exchange.wast contracts/exchange/exchange.abi
```

If you don't need walletd afterwards, you can stop the walletd service using

```bash
docker-compose stop walletd
```
### Change default configuration

You can use docker compose override file to change the default configurations. For example, create an alternate config file `config2.ini` and a `docker-compose.override.yml` with the following content.

```yaml
version: "2"

services:
  cpsd:
    volumes:
      - cpsd-data-volume:/opt/cps/bin/data-dir
      - ./config2.ini:/opt/cps/bin/data-dir/config.ini
```

Then restart your docker containers as follows:

```bash
docker-compose down
docker-compose up
```

### Clear data-dir
The data volume created by docker-compose can be deleted as follows:

```bash
docker volume rm docker_cpsd-data-volume
```
