# collecting some N2k things on webbrowsers
## Firefox and Derivates
### SQLite Magix
- connect to sqlite<br>
  - e.g. use `sqlite3` from your linux repo
  - run `sqlite3 <your sqlite db file> "<your select statements>"`
  - e.g. get all mozilla tables available<br>
    ```
    sqlite3 places.sqlite "SELECT name FROM sqlite_master WHERE type='table' "
    moz_origins
    moz_places
    moz_historyvisits
    moz_inputhistory
    moz_bookmarks
    moz_bookmarks_deleted
    moz_keywords
    sqlite_sequence
    moz_anno_attributes
    moz_annos
    moz_items_annos
    moz_meta
    moz_places_metadata
    moz_places_metadata_search_queries
    moz_previews_tombstones
    sqlite_stat1
    moz_places_extra
    moz_historyvisits_extra
    ```
