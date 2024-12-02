# RAIDing-the-Fort

This documentation provides an overview of how the RAID simulation and attack simulation works in the `vuln.sh` script.

## Table of Contents
1. [Introduction]
2. [RAID Configuration Options]
3. [Creating RAID Arrays]
4. [Simulating RAID Attacks]
5. [Output Analysis]

---

## 1. Introduction

The script simulates various RAID configurations and attacks on RAID arrays, allowing users to observe the effects of RAID operations and their vulnerability to various attacks. The script includes the following stages:

- **RAID Configuration Selection:** User selects the type of RAID array to create.
- **RAID Creation Process:** Script sets up the RAID array and displays its status.
- **Disk Attack Simulation:** Users can simulate different disk attacks, such as disk failures or disk corruption.

---

## 2. RAID Configuration Options

### Menu Choices:

1. **RAID 0 (Striping):** Data is split across multiple disks, providing higher performance at the cost of redundancy.
2. **RAID 1 (Mirroring):** Data is duplicated across two or more disks, providing redundancy.
3. **RAID 5 (Striped with Parity):** Data is striped across multiple disks with parity for redundancy.
4. **RAID 6 (Striped with Double Parity):** Similar to RAID 5 but with an additional level of parity, allowing for two disk failures.
5. **Exit:** Exit the script.

After the user selects a RAID configuration, the script moves forward to create the array based on the choice.

---

## 3. Creating RAID Arrays

### RAID Creation Process:

- The script first identifies and uses loopback devices (e.g., `/dev/loop0`, `/dev/loop1`, etc.).
- It clears any existing RAID metadata on the selected disks.
- After clearing metadata, the script proceeds to create the selected RAID array.
- If the array involves multiple disks (e.g., RAID 5 or RAID 6), the script will ensure that the necessary number of disks are available.
  
### Sample Output for RAID 1:

```
Choose a RAID configuration:
1) RAID 0 (Striping)
2) RAID 1 (Mirroring)
3) RAID 5 (Striped with Parity)
4) RAID 6 (Striped with Double Parity)
5) Exit
Enter your choice: 2
Setting up loop devices...
Using devices: /dev/loop0 /dev/loop1 /dev/loop2 /dev/loop3
Clearing RAID metadata from disks...
Stopping all active RAID arrays...
RAID metadata cleared.
Creating RAID 1 with /dev/loop0 /dev/loop1 /dev/loop2 /dev/loop3...
```

If the user chooses RAID 1, the array is created with the specified loop devices, and the script displays messages indicating the status and any issues encountered.

---

## 4. Simulating RAID Attacks

### Available Attacks:

1. **Simulate Disk Corruption Attack:** Corrupt data on a specific disk in the array.
2. **Simulate Disk Failure Attack:** Force a disk failure in the RAID array.
3. **Simulate Multiple Disk Failures (RAID 5/6 only):** Simulate failures in multiple disks in RAID 5 or RAID 6 arrays.
4. **Exit:** Exit the script.

The attack simulation can be performed after the RAID array is successfully created. The script simulates a disk failure or corruption attack by removing a disk from the array or modifying disk contents.

### Sample Attack Simulation (Disk Failure):

```
Choose a demonstration attack to simulate on RAID:
1) Simulate Disk Corruption Attack
2) Simulate Disk Failure Attack
3) Simulate Multiple Disk Failures (RAID 5/6 only)
4) Exit
Enter your choice: 2
Simulating disk failure on /dev/loop0...
mdadm: hot removed /dev/loop0 from /dev/md1
Disk /dev/loop0 marked as failed.
Displaying disk contents and RAID status...
Contents of /dev/loop0:
[Hexadecimal content displaying disk data]
```

After the disk failure simulation, the RAID array status is updated to show which disks are active, and the array will go into a degraded state if a disk failure occurs.

---

## 5. Output Analysis

The script provides a detailed output for each stage:

### RAID Creation:

- Displays information about the RAID version, creation time, raid level, array size, and status (e.g., `resyncing` or `clean`).
- Provides the RAID array status and its health (e.g., `active sync`, `failed`, etc.).
  
### Sample RAID Array Status:

```
RAID Array Status:
/dev/md1:
           Version : 1.2
     Creation Time : Mon Dec  2 20:51:36 2024
        Raid Level : raid1
        Array Size : 101376 (99.00 MiB 103.81 MB)
     Used Dev Size : 101376 (99.00 MiB 103.81 MB)
      Raid Devices : 2
     Total Devices : 2
       Persistence : Superblock is persistent

       Update Time : Mon Dec  2 20:51:36 2024
             State : clean, resyncing
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 0
     Spare Devices : 0
```

### Simulating Disk Failures:

- After performing a disk failure simulation, the script updates the RAID status, marking the disk as "failed" and displaying its contents.
  
### Disk Content Changes:

Each disk’s contents will be shown in hexadecimal form, helping users to understand how the data on each disk is structured and what happens when a failure or corruption occurs.

Example:
```
Contents of /dev/loop0:
00000000  76 7f 57 c2 33 9b d4 fb  67 39 1b c7 36 ef dd 41  |v.W.3...g9..6..A|
...
```

---

## Conclusion

The script provides a comprehensive simulation of RAID operations and attacks, making it a valuable tool for understanding how RAID arrays handle different failure scenarios and vulnerabilities. The output helps visualize the real-time impact of RAID configurations and attack simulations on storage systems.

