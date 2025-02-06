🚧
Output by Perplexity:

To change the path for KVM images inside RHEL, follow these steps:

1. Stop all running virtual machines:
```bash
sudo virsh shutdown <vm_name>
```

2. List the current storage pool:
```bash
sudo virsh pool-list
```

3. Stop the default storage pool:
```bash
sudo virsh pool-destroy default
```

4. Edit the default storage pool configuration:
```bash
sudo virsh pool-edit default
```

5. In the XML file, locate the `<path>` element under the `<target>` directive and change it to your desired new path[1][3]. For example:
```xml
<path>/home/vms</path>
```

6. Save and exit the editor.

7. Start the default storage pool with the new path:
```bash
sudo virsh pool-start default
```

8. Verify the new path:
```bash
sudo virsh pool-dumpxml default | grep -i path
```

9. Move existing VM image files to the new location:
```bash
sudo mv /var/lib/libvirt/images/<vm_name>.qcow2 /home/vms/
```

10. Update each VM's configuration to reflect the new image path:
```bash
sudo virsh edit <vm_name>
```
Change the `<source file>` element to point to the new location[2][3].

11. Start your virtual machines:
```bash
sudo virsh start <vm_name>
```

Remember to create the new directory before changing the path, and ensure you have sufficient permissions and storage space in the new location[3]. If you encounter SELinux-related issues, you may need to adjust SELinux contexts or temporarily set it to permissive mode[3].

Citations:
[1] https://ostechnix.com/how-to-change-kvm-libvirt-default-storage-pool-location/
[2] https://gist.github.com/plembo/5e108dc8000850442d756fc3747d31a3
[3] https://www.informaticar.net/change-kvm-libvirt-default-storage-path/
[4] https://www.unixarena.com/2015/12/linux-kvm-change-libvirt-vm-image-store-path.html/
[5] https://access.redhat.com/solutions/966703
[6] https://serverfault.com/questions/900824/how-to-move-kvm-image-to-another-directory-partition
[7] https://access.redhat.com/solutions/301353
[8] https://www.reddit.com/r/linuxquestions/comments/tkgqdu/how_to_change_storage_path_for_libvirt/

---
Answer from Perplexity: https://www.perplexity.ai/search/rhel-get-kvm-machines-CoOz0nwbRCGdgyjVpyKcRQ?utm_source=copy_output
