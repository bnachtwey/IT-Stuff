# Changing the path of the "default storage pool"

![Under Construction](../../.pictures/Under_Construction_Medium.png)

<!--
AIA No AI, _This work was entirely human-created, without the use of AI._

# changelog
# date          version    remark
# 2026-02-11    0.1        initial coding

-->

> [!Info]
>
> Typically the KVM hypervisor put the storage of the KVM to `/var/lib/libvirt/images/` -- typically a partion / volume with *limited space*
>
> Therefore moving the storage location, e.g. to a dedicated disk or volume, sounds like a considerable idea ;-)

## Step-by-Step-Guide

### 1) Shutdown all VMs

> Moving existing machines cannot be done while they are running, so first shut down all VMs

```bash
for v in $(virsh list | awk '(NR>2) {print $2}')
do
  virsh shutdown ${v}
  sleep 2
done
```

or as *oneliner*

```bash
for v in $(virsh list | awk '(NR>2) {print $2}'); do virsh shutdown ${v} && sleep 2; done
```

### 2) stop pool

Don't panic, althoug it's called `destroy` :-)

```bash
virsh pool-destroy default
```

cross check

```bash
# virsh pool-list --all
 Name      State      Autostart
---------------------------------
 default   inactive   yes

```

`inactive` is the key word

### 3) move existing data to new location

```bash
cp -a /var/lib/libvirt/images <NEW LOCATION>
```

### 4) edit KVM/qemu settings

change entry `<path>` in the `<target>` section:

```bash
virsh pool-edit default
```

e.g.

```xml
<pool type='dir'>
  <name>default</name>
  <uuid>ca5b060d-2a93-486d-ab63-689bb9a882ba</uuid>
  <capacity unit='bytes'>107302879232</capacity>
  <allocation unit='bytes'>5330284544</allocation>
  <available unit='bytes'>101972594688</available>
  <source>
  </source>
  <target>
    <path>/<NEW LOCATION>/images</path>
    <permissions>
      <mode>0755</mode>
      <owner>107</owner>
      <group>107</group>
      <label>unconfined_u:object_r:unlabeled_t:s0</label>
    </permissions>
  </target>
</pool>
```

### 5) start pool again

```bash
virsh pool-start default
```

cross check

```bash
# virsh pool-list --all
 Name      State    Autostart
-------------------------------
 default   active   yes
```

### 6) Start KVM again

```bash
virsh start <KVM>
```
