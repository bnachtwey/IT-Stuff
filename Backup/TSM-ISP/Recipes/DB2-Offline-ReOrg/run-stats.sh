#! /bin/bash

# changelog
# date        version remark
# 2023-11-12  0.2.1a  moved to new repo
# 2023-11-10  0.2.1   added some tables and replaces tabs with 2 spaces 
# 2023-09-20  0.2.0   forking & moved to github, add some formal stuff
# 2020-08-12  0.1.0   first version put to gitlab
# 2020-08-XX  0.0.1   initial coding using bash
#
##############################################################################
#
#  run-stats.sh
# 
#   runing db2 runstats for all tables
#
#   The Author:
#   (C) 2020 -- 2023 Bjørn Nachtwey, tsm@bjoernsoe.net
#
#   Grateful Thanks to the Companies, who allowed to do the development
#   (C) 2023         Cristie Data Gmbh, www.cristie.de
#   (C) 2020 -- 2023 GWDG, www.gwdg.de
#
##############################################################################
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
##############################################################################

# define tables to do runstats
# => remove the ones not reorganized
# running runstats on all tables causes no problems ... but costs time

tables=(                      \
    "ACTIVITY_LOG"            \
    "AF_SEGMENTS"             \
    "AF_BITFILES"             \
    "ARCHIVE_OBJECTS"         \
    "AS_SEGMENTS"             \
    "BACKUP_OBJECTS"          \
    "BF_AGGREGATE_ATTRIBUTES" \
    "BF_AGGREGATED_BITFILES"  \
    "BF_BITFILE_EXTENTS"      \
    "BF_DEREFERENCED_CHUNKS"  \
    "GROUP_LEADERS"           \
    "EXPORT_OBJECTS"          \
    "REPLICATED_OBJECTS"      \
    "SC_OBJECT_TRACKER"       \
    "SD_CHUNK_LOCATIONS"      \       
    "SD_RECON_ORDER"          \
    "SD_REPLICATED_CHUNKS"    \
    "TSMMON_STATUS"           )

# connect to db2
db2 connect to tsmdb1

# do runstats 
for tab in ${tables[@]}
do
  db2 "RUNSTATS ON TABLE tsmdb1.$tab WITH DISTRIBUTION AND SAMPLED DETAILED INDEXES ALL"
done
