#! /bin/bash
##############################################################################
#
# changelog
# date      version remark
# 2023-11-10  0.1.2   some more tables added ()
# 2023-02-20  0.1.1   moved changelog to top, added some tables
# 2020-08-12  0.1.0   first version put to gitlab
# 2020-08-XX  0.0.1   initial coding using bash
#
##############################################################################
#
#  reorg-tables.sh
# 
#  doing all reorgs in one script call
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

# copy / edit following part and skip lines not needed

exit 99;  # so running this script without any editing it fails

tables08K=(                   \
    "REPLICATED_OBJECTS"      )
tables16K=(                   \
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
tables32K=(                      \
    "ARCHIVE_OBJECTS"         \
    "BACKUP_OBJECTS"          )

db2 connect to tsmdb1 && \
for tab in ${tables32K[@]}
do
  db2 "reorg table tsmdb1.$tab allow no access use REORG32K"
done && \
for tab in ${tables16K[@]}
do
  db2 "reorg table tsmdb1.$tab allow no access use REORG16K"
done && \
for tab in ${tables08K[@]}
do
  db2 "reorg table tsmdb1.$tab allow no access use REORG8K"
done