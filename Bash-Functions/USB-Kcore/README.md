# USB Kcore A collection of checkpoint tools

This tool is to allow recording a Checkpoint Kernel core dump to a USB drive.
This is useful for when the storage is too full or small to save the core.

Due to how the rc.init script for kdump works on Gaia it doesn't respect most values
inside of the kdump.conf so we have to implement a post script that runs after kdump-post
to copy the core dump to the USB. This script should run regardless of if there
is space on the disk to save the core dump in /var/log/crash. So the core may
still be found there with this procedure implemented if there is enough space.

## Instructions

### Prepare the USB drive

The USB storage drive should be ideally the same size or greater than
the total ram on the system. We will be using gzip to compress the vmcore,
however depending on how much data is in ram the compression's effectiveness
will vary. So for example if your system has a total of 32GB of ram installed
ensure the USB drive is at least 32GB in size.

Once the proper size drive has been obtained we need to format it and fetch the
UUID of the drive to ensure it gets mounted properly on time of crash.

Use the following commands to wipe the USB drive and create the ext4 partition.
These command can be run on the Checkpoint system if required
<!-- markdownlint-disable MD013 -->
```bash
# List disks to determine what the usb disk is labelled as
fdisk -l
# Once we know the disk label (in this case we are assuming /dev/sdz) we clear the disk
fdisk /dev/sdz
# use the interactive menu options to delete partitions
d # deletes partition run this until fdisk tells you all paritions are gone
w # write changes to disk
q # quit fdisk interactive menu
```
<!-- markdownlint-enable MD013 -->

Now that the disk is cleared create a new single partition on the drive.
<!-- markdownlint-disable MD013 -->
```bash
# Use the disk label again to enter fdisk
fdisk /dev/sdz
# use the interactive menu options to create the partition
n # use N to create a new partition
p # select a primary paritions
# When asked partition number or start and end sectors keep the defaults
# This can be done by inputting nothing and hitting enter
# If asked to clear the old partition signature input Y and enter
w # write changes to disk
q # quit fdisk interactive menu

# Finally verify the partition is there
fdisk -l
```
<!-- markdownlint-enable MD013 -->
Format the new partition with ext4
<!-- markdownlint-disable MD013 -->
```bash
mkfs.ext4 /dev/sdz1
```
<!-- markdownlint-enable MD013 -->

### Configure the system to copy the core to usb

Gather the UUID of the new partitions
<!-- markdownlint-disable MD013 -->
```bash
blkid /dev/sdz1
# Example output
/dev/sdz1: UUID="33c4f0cd-d4f1-4f72-8a52-74445a1dec9b" BLOCK_SIZE="4096" TYPE="ext4" PARTUUID="84be2329-01"
# The value we want to extract from this is 33c4f0cd-d4f1-4f72-8a52-74445a1dec9b
```
<!-- markdownlint-enable MD013 -->
At the top of the kdump-post.sh script there is a USB-UUID field,
insert your collected value there. Ensure that the value is surrounded
by a single set of quotations as per the pre-populated value.

Now create the required scripts folder and upload the script to that location
<!-- markdownlint-disable MD013 -->
```bash
# Create the required folder
mkdir -p /var/log/crash/scripts

# Copy the script to that folder
# I'm assuming the script is in /home/admin
cp /home/admin/kdump-post.sh /var/log/crash/scripts/kdump-post.sh

# Ensure the script is executable
chmod +x /var/log/scripts/kdump-post.sh
dos2unix /var/log/scripts/kdump-post.sh
```
<!-- markdownlint-enable MD013 -->

We need to edit the /etc/kdump.conf file to ensure it has these
UNCOMMENTED line in it.
<!-- markdownlint-disable MD013 -->
```bash
kdump_post /var/log/crash/scripts/kdump-post.sh
```
<!-- markdownlint-enable MD013 -->

### Verifying it's working properly

When the kdump process is invoked the initram environment will
call the kdump-post.sh script after it's finished it's tasks.
This will mount our storage device and copy and compress the file from memory
(/proc/vmcore) to our USB drive.

Finally we can test to make sure everything's working by
manually crashing the kernel with the following command.
Please take sane precautions like doing this on the standby
and out of production hours if it all possible.
<!-- markdownlint-disable MD013 -->
```bash
# Cause a kernel crash, rebooting the system.
echo c > /proc/sysrq-trigger
```
<!-- markdownlint-enable MD013 -->

Once the system has booted mount and check the usb drive to Ensure
the core dump file is present. By default It should be located in the directory

./kdumps/$HOSTNAME/$DATE>/vmcore.gz

By Default anything logged by the script will be located on the system at
/var/log/crash/kdump-post.log
