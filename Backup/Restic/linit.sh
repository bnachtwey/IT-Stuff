#! /bin/bash

workdir=/local/Restic

export RESTIC_REPOSITORY=$(cat ${workdir}/config/Repo.local)
export RESTIC_PASSWORD=$(  cat ${workdir}/config/Restic-Password.local)

restic init
