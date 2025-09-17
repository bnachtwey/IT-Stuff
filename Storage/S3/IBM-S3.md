# Comparing IBM offerings for S3 2 Tape Solutions

The **set of supported S3 operations is different** between **IBM Storage Protect (SP)** and **IBM Storage Deep Archive**, due to their distinct architectural purposes and integration layers.

## 🔍 Comparison of S3 API Operations

| Operation | IBM Storage Protect (SP) | [IBM Storage Deep Archive](https://www.tenforums.com/tutorials/158668-how-mount-unmount-drive-volume-windows.html) |
|-----------|---------------------------|---------------------------|
| `PUT Bucket` | ✅ Creates a filespace | ❌ Not applicable (buckets managed via gateway or lifecycle policies)  |
| `DELETE Bucket` | ✅ Deletes a filespace (must be empty) | ❌ Typically not supported directly; deletion via lifecycle rules |
| `LIST Buckets` | ✅ Lists all filespaces | ❌ Bucket listing depends on gateway implementation  |
| `PUT Object` | ✅ Stores object in SP storage pool | ✅ Stores object in tape-backed archive  |
| `GET Object` | ✅ Immediate retrieval | ✅ Retrieval with delay (Glacier-style)  |
| `DELETE Object` | ✅ Deletes object | ✅ Deletes object (may require lifecycle policy)  |
| `HEAD Object` | ❌ Not supported  | ✅ Supported (for metadata checks)  |
| `LIST Objects` | ✅ Supported | ✅ Supported  |
| `POST Object Restore` | ❌ Not applicable | ✅ Required for Glacier-style retrieval |
| `PUT Lifecycle` | ❌ Managed via SP policies | ✅ Supported for archival and deletion  |

**Summary**

- **IBM SP** supports a **basic subset** of S3 operations tailored for backup workflows, with buckets mapped to filespaces and limited metadata handling.
- **IBM Deep Archive** supports a **broader set of S3 Glacier-compatible operations**, including lifecycle management and delayed retrieval, optimized for long-term archival.
