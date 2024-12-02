cat vuln.sh 
#!/bin/bash

# Color codes
NC='\033[0m'  # No color
BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'

# RAID configuration
RAID_NAME="/dev/md0"
DISKS=()

# Function to simulate disk data corruption (attack)
simulate_disk_attack() {
    local attack_disk=$1
    echo -e "${YELLOW}${BOLD}Simulating disk attack on $attack_disk...${NC}"
    echo -e "${RED}Overwriting data on $attack_disk with random data.${NC}"

    # Print RAID status and disk contents before the attack
    show_disks_and_status

    sudo dd if=/dev/urandom of=$attack_disk bs=1M count=10 status=none
    echo -e "${RED}Disk $attack_disk attacked! Data corruption simulated.${NC}"

    # Print RAID status and disk contents after the attack
    show_disks_and_status
}

# Function to simulate disk failure (attack)
simulate_disk_failure() {
    local failed_disk=$1
    echo -e "${YELLOW}${BOLD}Simulating disk failure on $failed_disk...${NC}"
    sudo mdadm --fail $RAID_NAME $failed_disk
    sudo mdadm --remove $RAID_NAME $failed_disk
    echo -e "${RED}Disk $failed_disk marked as failed.${NC}"
    show_disks_and_status
}

# Function to simulate a multi-disk failure attack (RAID 5/6 vulnerability)
simulate_multiple_disk_failures() {
    echo -e "${YELLOW}${BOLD}Simulating multiple disk failures...${NC}"
    # RAID 5 or RAID 6 specific attack
    if [[ "$RAID_LEVEL" -eq 5 || "$RAID_LEVEL" -eq 6 ]]; then
        local failed_disk_1=${DISKS[0]}
        local failed_disk_2=${DISKS[1]}
        simulate_disk_failure $failed_disk_1
        simulate_disk_failure $failed_disk_2
    else
        echo -e "${RED}Multiple disk failure attack can only be simulated on RAID 5 or RAID 6.${NC}"
    fi
}

# Function to display disk contents and RAID status
show_disks_and_status() {
    echo -e "${BLUE}${BOLD}Displaying disk contents and RAID status...${NC}"
    for disk in "${DISKS[@]}"; do
        if [[ -b $disk ]]; then
            echo -e "${YELLOW}Contents of $disk:${NC}"
            sudo hexdump -C $disk | head -n 10
        else
            echo -e "${RED}$disk is not accessible.${NC}"
        fi
    done
    echo -e "\n${GREEN}RAID Array Status:${NC}"
    sudo mdadm --detail $RAID_NAME || echo -e "${RED}RAID array $RAID_NAME is not active.${NC}"
}

# Function to configure RAID
configure_raid() {
    local raid_level=$1
    RAID_LEVEL=$raid_level

    # Setup loop devices and clear metadata
    setup_loop_devices
    clear_raid_metadata

    echo -e "${BLUE}${BOLD}Creating RAID $raid_level with ${DISKS[*]}...${NC}"
    if [ "$raid_level" == "0" ]; then
        sudo mdadm --create $RAID_NAME --level=0 --raid-devices=2 ${DISKS[@]:0:2}
    elif [ "$raid_level" == "1" ]; then
        sudo mdadm --create $RAID_NAME --level=1 --raid-devices=2 ${DISKS[@]:0:2}
    elif [ "$raid_level" == "5" ]; then
        sudo mdadm --create $RAID_NAME --level=5 --raid-devices=3 ${DISKS[@]:0:3}
    elif [ "$raid_level" == "6" ]; then
        sudo mdadm --create $RAID_NAME --level=6 --raid-devices=4 ${DISKS[@]}
    else
        echo -e "${RED}Invalid RAID level.${NC}"
        return 1
    fi
    echo -e "${GREEN}RAID $raid_level array created successfully.${NC}"
    show_disks_and_status
}

# Function to setup loop devices and ensure they exist
setup_loop_devices() {
    echo -e "${BLUE}${BOLD}Setting up loop devices...${NC}"
    DISKS=()
    for i in {0..3}; do
        disk_file="/tmp/disk$i.img"
        if [[ ! -f $disk_file ]]; then
            echo -e "${RED}Disk image $disk_file does not exist. Creating it...${NC}"
            sudo dd if=/dev/zero of=$disk_file bs=1M count=10
        fi
        loop_device=$(sudo losetup -f --show $disk_file 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            DISKS+=("$loop_device")
        else
            echo -e "${RED}Failed to attach loop device for $disk_file.${NC}"
        fi
    done

    if [[ ${#DISKS[@]} -lt 2 ]]; then
        echo -e "${RED}Insufficient devices. You need at least 2 devices for RAID 1.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Using devices: ${DISKS[*]}${NC}"
}

# Function to clean up loop devices
cleanup_loop_devices() {
    echo -e "${BLUE}${BOLD}Cleaning up loop devices...${NC}"
    for disk in "${DISKS[@]}"; do
        sudo losetup -D
    done
}

# Function to stop all active RAID arrays
stop_all_raid_arrays() {
    echo -e "${BLUE}${BOLD}Stopping all active RAID arrays...${NC}"
    for md in /dev/md*; do
        if [[ -b $md ]]; then
            echo -e "${YELLOW}Stopping array $md...${NC}"
            sudo mdadm --stop $md
        fi
    done
}

# Function to clear RAID metadata
clear_raid_metadata() {
    echo -e "${BLUE}${BOLD}Clearing RAID metadata from disks...${NC}"
    stop_all_raid_arrays
    for disk in "${DISKS[@]}"; do
        sudo mdadm --zero-superblock $disk
    done
    echo -e "${GREEN}RAID metadata cleared.${NC}"
}

# Function to restore to original state
restore_disks() {
    echo -e "${BLUE}${BOLD}Restoring disks to their original state...${NC}"
    cleanup_loop_devices
    echo -e "${GREEN}Disks restored to their original state.${NC}"

    echo -e "\n\n${YELLOW}${BOLD} Thank you for using hte RAID levels and Vulerability Simulator ~ Het Joshi "
}

# Main script loop
while true; do
    echo "
    RRRR    AAAAA  III DDDD       SSSSS  III M     M  U   U  L      AAAAA  TTTTT  OOO  RRRR
    R   R  A     A  I   D   D     S       I  MM   MM  U   U  L     A     A   T   O   O R   R
    RRRR   AAAAAAA  I   D   D     SSSSS   I  M M M M  U   U  L     AAAAAAA   T   O   O RRRR
    R  R   A     A  I   D   D         S   I  M  M  M  U   U  L     A     A   T   O   O R  R
    R   R  A     A  I   DDDD      SSSSS   I  M     M  UUUUU  LLLLL A     A   T    OOO  R   R

    		By: Het Joshi
    "

    echo -e "\nChoose a RAID configuration:"
    echo -e "1) RAID 0 (Striping)"
    echo -e "2) RAID 1 (Mirroring)"
    echo -e "3) RAID 5 (Striped with Parity)"
    echo -e "4) RAID 6 (Striped with Double Parity)"
    echo -e "5) Exit"

    read -p "Enter your choice: " choice
    case $choice in
        1)
            RAID_NAME=/dev/md0
            configure_raid 0
            ;;
        2)
            RAID_NAME=/dev/md1
            configure_raid 1
            ;;
        3)
            RAID_NAME=/dev/md2
            configure_raid 5
            ;;
        4)
            RAID_NAME=/dev/md3
            configure_raid 6
            ;;
        5)
            restore_disks
            break
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            ;;
    esac

    # Simulate attack based on RAID level
    echo -e "\nChoose a demonstration attack to simulate on RAID:"
    echo -e "1) Simulate Disk Corruption Attack"
    echo -e "2) Simulate Disk Failure Attack"
    echo -e "3) Simulate Multiple Disk Failures (RAID 5/6 only)"
    echo -e "4) Exit"
    read -p "Enter your choice: " attack_choice
    case $attack_choice in
        1)
            attack_disk=${DISKS[0]}
            simulate_disk_attack $attack_disk
            ;;
        2)
            attack_disk=${DISKS[0]}
            simulate_disk_failure $attack_disk
            ;;
        3)
            simulate_multiple_disk_failures
            ;;
        4)
            echo -e "${GREEN}Exiting attack simulations.${NC}"
            ;;
        *)
            echo -e "${RED}Invalid attack choice.${NC}"
            ;;
    esac
done


stop_all_raid_arrays
cleanup_loop_devices
                                                     
