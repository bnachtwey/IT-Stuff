# Known Return Codes

| Name | Number | Meaning |
| :-- | :-- | :-- |
| rc_ok | 0 | Command completed successfully |
| rc_notfound | 11 | Object not found or node does not exist |
| rc_warning | 3 | Command completed with warnings |
| rc_error | 8 | Command completed with errors |
| rc_exists | 10 | Object already exists (e.g., node already registered) |

**Notes on usage:**

- **rc_ok (0):** Indicates the command executed without errors [[3]](https://www.ibm.com/support/pages/apar/IT17914).
- **rc_notfound (11):** Returned when a node or object is not found, such as when registering a node that already exists or referencing a nonexistent object [[1]](https://adsm.org/forum/index.php?threads%2Fdsmadmc-return-codes.12715%2F)([4)](https://adsm.org/lists/html/adsm-l/2002-03/msg02128.html).
- **rc_warning (3):** Indicates a warning was issued, but the command generally completed[[2]](https://www.ibm.com/support/pages/dsmadmc-non-interactive-mode-produces-unexpected-results).
- **rc_exists (10):** Indicates an attempt to create or register an object that already exists (e.g., registering an existing node) [[1]](https://adsm.org/forum/index.php?threads%2Fdsmadmc-return-codes.12715%2F).
- **rc_error (8):** Indicates a command failed due to errors (inferred from standard IBM return code conventions; not explicitly listed in the provided results, but commonly used in IBM command-line tools).

If you need a complete, official list, IBM documentation for the specific TSM/Spectrum Protect version in use is recommended, as return codes can vary slightly between releases. The above codes are the most commonly encountered in scripts and automation with dsmadmc.
