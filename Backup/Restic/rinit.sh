#! /bin/bash

workdir=/local/Restic

export RESTIC_REPOSITORY=$(cat ${workdir}/config/Repo.remote)
export RESTIC_PASSWORD=$(  cat ${workdir}/config/Restic-Password.remote)

restic init
