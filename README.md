# Grzesbank24 - runner repo

#### Quickstart

To run GB24 app locally clone this repo, `cd` inside and type:
`chmod a+x ./*.sh`
and to run:
`./run-docker.sh`

#### Run helper script `./gb24-runner.sh`
Takes in options, as below:
- `--clean` - cleans tmp folder of the script
- `--pull` - pulls latest changes from git repos (master branches)
  - Change gb24-api branch with `-I <branch_name>`
  - Change gb24-app branch with `-P <branch_name>`
- `--gen-cert` generates self-signed SSL certs for 30 days
- `--no-daemon` disables `-d` option in `docker compose`
- `--build` forces `docker compose` to rebuild images
