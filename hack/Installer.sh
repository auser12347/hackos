#!/bin/bash

clear

echo "======= HACKOS INSTALLER ======="
echo
echo "Welcome to hackOS installer. "
while true; do
	echo "Please choose an option:"
	echo " 1. Show lsblk"
	echo " 2. Open GParted"
	echo " 3. Choose root partition"
	echo " 4. Choose EFI partition"
	echo " 5. Recommended partition setup"
	echo " 6. Exit"
	echo " 7. Proceed"
	echo
	echo "------"
	echo
	echo "Configurations: "
	echo " Root partition: $PART"
	echo " Efi partition: $EFIPAR"
	echo -n ">> "
	read option
	case "$option" in
		1)
			lsblk
			echo
			;;
		2)
			/usr/sbin/gparted
                        clear
                        echo "======= HACKOS INSTALLER ======="
                        echo
                        echo "Welcome to hackOS installer. "
			;;
		3)
			read -p "Enter partition: " PART
			TYPE=$(lsblk -no TYPE "$PART")
			if [ "$TYPE" != "part" ]; then
				echo "Invalid partition."
				PART=
			else
				echo "You have selected partition $PART for root."
			fi
			echo "Press any key to continue..."
			read -n 1 -s
			clear
			echo "======= HACKOS INSTALLER ======="
			echo
			echo "Welcome to hackOS installer. "
			;;
		4)
			read -p "Enter partition: " EFIPAR
			TYPE=$(lsblk -no TYPE "$EFIPAR")
			if [ "$TYPE" != "part" ]; then
				echo "Invalid partition."
				EFI=
			else
				echo "You have selected partition $EFIPAR for EFI."
			fi
			echo "Press any key to continue..."
			read -n 1 -s
			clear
			echo "======= HACKOS INSTALLER ======="
			echo
			echo "Welcome to hackOS installer. "
			;;
		6)
			exit
			;;
		5)
			FILE="$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 16)"
			cp /hack/recommendpar.txt "/tmp/$FILE"
			nano "/tmp/$FILE"
			rm "/tmp/$FILE"
			clear
			echo "======= HACKOS INSTALLER ======="
			echo
			echo "Welcome to hackOS installer. "
			;;
		7)
			echo "Are you sure you want to proceed these changes? [y/n]"
			echo "(default user password is 1234)"
			echo -n ">"
			read -n 1 -s YESNOQUESTION
			case "$YESNOQUESTION" in
				y)
					echo "$PART" > /tmp/rootpar
					echo "$EFIPAR" > /tmp/efipar
					sudo bash /hack/install.sh
					echo "installation has completed. You may restart now."
					echo "Press any key to exit..."
					read -n 1 -s
					exit
			esac
			clear
			echo "======= HACKOS INSTALLER ======="
			echo
			echo "Welcome to hackOS installer. "
	esac
done
