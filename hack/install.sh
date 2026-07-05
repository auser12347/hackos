#!/bin/bash
set -e

EFI="$(cat /tmp/efipar)"
ROOT="$(cat /tmp/rootpar)"

if [ "$EFI" = "" ]; then
  echo "You didn't assign the EFI partition yet. WTF is wrong with you?"
  exit
fi

if [ "$ROOT" = "" ]; then
  echo "You didn't assign the root partition yet. WTF is wrong with you?"
  exit
fi

# ---------- MOUNT TARGET ----------
echo "[*] Mounting root partition..."
mount "$ROOT" /mnt

echo "[*] Mounting EFI partition..."
mkdir -p /mnt/boot/efi
mount "$EFI" /mnt/boot/efi

# ---------- CLONE SYSTEM ----------
echo "[*] Cloning system..."
rsync -aAXH --numeric-ids \
  --exclude={"/dev/*","/proc/*","/sys/*","/run/*","/tmp/*","/mnt/*","/media/*","/lost+found"} \
  / /mnt

# ---------- BIND SYSTEM ----------
echo "[*] Preparing chroot..."
for i in dev proc sys run; do
  mount --bind /$i /mnt/$i
done

# ---------- CHROOT CONFIG SCRIPT ----------
cat > /mnt/root/setup.sh << EOF
#!/bin/bash

echo "[CHROOT] Configuring system..."

cat > /etc/hosts << EOH
127.0.0.1 localhost
127.0.1.1 hackos
EOH

# hostname
echo "hackos" > /etc/hostname

rm /hack/install.sh
rm /hack/Installer.sh
rm /home/hacker/Desktop/Installer.sh

apt update
apt install -y linux-image-amd64

update-initramfs -u

# GRUB install (UEFI system assumed)
if command -v grub-install >/dev/null 2>&1; then
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=hackos
  grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "[CHROOT] Done"
EOF

chmod +x /mnt/root/setup.sh

# ---------- RUN CHROOT ----------
echo "[*] Entering chroot..."
chroot /mnt /root/setup.sh

# ---------- CLEANUP ----------
echo "[*] Unmounting..."
for i in run sys proc dev boot/efi; do
  umount -l /mnt/$i 2>/dev/null || true
done

umount -l /mnt

# echo "DONE ✔ Installation complete"
