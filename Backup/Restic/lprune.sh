#! /bin/bash

workdir=/local/Restic
export RESTIC_REPOSITORY=$(cat ${workdir}/config/Repo.local)
export RESTIC_PASSWORD=$(  cat ${workdir}/config/./Restic-Password.local)

today=$(date "+%F")

logfile=${workdir}/log/$today.prune.local.log

# check if prune log exits
if [ -s "${logfile}" ]
then
    echo "Pruning was already done today. Exit"
    exit 0
fi

# check for locks
if [ $(restic list locks) ]
then 
    echo "($(date "+%a %F %R %Z")) :: Need to unlock repo!" >> ${workdir}/log/unlock.log
    restic unlock 
fi

starttime=$(date "+%a %F %R %Z")
echo "##########################################################################"   >> ${logfile}
echo "### START: $starttime"                                                        >> ${logfile}
echo "##########################################################################"   >> ${logfile}
echo "### forget"                                                                   >> ${logfile}
restic forget --keep-within-hourly 96h --keep-within-daily 30d --keep-within-weekly 3m --keep-within-monthly 1y >> ${logfile}
echo "##########################################################################"   >> ${logfile}
echo "### prune"                                                                    >> ${logfile}
restic prune                                                                        >> ${logfile}
echo "##########################################################################"   >> ${logfile}
echo "### Snapshots"                                                                >> ${logfile}
restic snapshots                                                                    >> ${logfile}
endtime=$(date "+%a %F %R %Z")
echo "##########################################################################"   >> ${logfile}
echo "### END: $endtime"                                                            >> ${logfile}
echo "##########################################################################"   >> ${logfile}
