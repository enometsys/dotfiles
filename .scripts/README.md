# Setup

### System
- install `intel-ucode` for intel microcode
- configure bootloader, either:
  - install `efibootmgr` to use `EFISTUB` directly instead of using bootloaders like `grub`
    ```sh
    # check partition PATUUIDs
    blkid
    # ESP (EFI System Partition) must be mounted on /boot
    # efibootmgr command (disk and part is the ESP disk and partition number, root PARTUUID is PARTUUID of root device)
    efibootmgr --verbose --disk /dev/sdX --part Y --create --label "Linux" --loader /vmlinuz-linux --unicode 'root=PARTUUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX rw initrd=\initramfs-linux.img'
    # efibootmgr command (with intel-ucode inserted before iniitramfs kernel param)
    efibootmgr --verbose --disk /dev/sdX --part Y --create --label "Linux" --loader /vmlinuz-linux --unicode 'root=PARTUUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX rw initrd=\intel-ucode.img initrd=\initramfs-linux.img'
    ```
  - use `systemd-boot`

### Bootstrap the system

```sh
# download the bootstrap script and run
# instead of directly piping to bash, tee first so it can be rerun w/o redownloading
curl -L -s 'https://raw.githubusercontent.com/enometsys/dotfiles/main/.scripts/bootstrap-system' | tee bootstrap-system | bash
```

### Create and setup user

```sh
# create user
useradd -m -G wheel -s /bin/zsh metsys

# install yadm
curl -fLo /usr/local/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x /usr/local/bin/yadm

# clone dotfiles and bootstrap
yadm clone https://github.com/enometsys/dotfiles.git --bootstrap
```

### Password store

- checked-in in github
- zipped and backed-up in cloud storage (on every push)

### OTP secrets and recovery codes

- managed by pass on a separate repo
- should be compiled, encrypted and encoded in QRCode w/c should be:
  - printed and laminated
  - backed-up in cloud storage
- OTPs should be registered in yubikey oath


### Yubikey

- TODO: [FDE using yubkey](https://github.com/agherzan/yubikey-full-disk-encryption) Challenge/response
- TODO: PAM-UTF using yubikey
  + login
  + sudo

##### Switching between two or more Yubikeys.

[TLDR](https://github.com/drduh/YubiKey-Guide#multiple-yubikeys); run:

```sh
gpg-connect-agent "scd serialno" "learn --force" /bye
```

### HIDPI

dotfiles (.Xresources, dwm/st config.def.h) are configured for HIDPI but must be lowered to accommodate non-HIDPI devices

```sh
# .Xresources
-Xft.dpi: 150
+Xft.dpi: 72

# .apps/dwm-6.2/config.def.h
 static const char *fonts[] = {
-  "Meslo LG M DZ:pixelsize=18:style=Bold:antialias=true:autohint=true",
+  "Meslo LG M DZ:pixelsize=10:style=Bold:antialias=true:autohint=true",
   "Symbola",
        "Liberation Mono"
 };

# .apps/st-0.8.2/config.def.h
-static char *font = "Liberation Mono:pixelsize=20:antialias=true:autohint=true";
+static char *font = "Liberation Mono:pixelsize=10:antialias=true:autohint=true";
 static int borderpx = 2;
```

### Device-specific configurations

#### Macbook Pro 12,1

https://wiki.archlinux.org/title/Mac

###### Power Management

- manage fan speed gradually - https://mchladek.me/post/arch-mbp/

###### Keyboard backlight


###### FacetimeHD webcam driver installation

https://github.com/patjak/bcwc_pcie/wiki/Installation#get-started-on-arch

Install `linux-headers` package
Install `bcwc-pcie-git` and `facetimehd-firmware` from AUR

Configure config files

```sh
# module params
$ tee /etc/modprobe.d/bcwc-pcie.conf <<EOF
blacklist bdc_pci\ninstall bdc_pci /bin/false
EOF

# modules to be loaded
$ tee /etc/modules-load.d/bcwc-pcie.conf <<EOF
facetimehd
EOF
```

###### Bluetooth headset - Connecting works, but there are sound glitches all the time

[solution src](https://wiki.archlinux.org/index.php/Bluetooth_headset#Connecting_works,_but_there_are_sound_glitches_all_the_time)

Occurs because the Bluetooth and the WiFi share the same chip as they share the same physical antenna and possibly band range (2.4GHz)

A possible solution is to move your WiFi network to 5GHz so that there will be no interference


###### Bluetooth Adapter disappers after suspend/resume or bluetoothctl commands shows 'No default controller available'**

[solution src](https://wiki.archlinux.org/index.php/Bluetooth#Adapter_disappears_after_suspend/resume) (ArchWiki)

First, find vendor and product ID of the adapter. For example:

```sh
$ lsusb -tv
----------------
/:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=xhci_hcd/12p, 480M
    ID 1d6b:0002 Linux Foundation 2.0 root hub
    ...
    |__ Port 3: Dev 3, If 0, Class=Wireless, Driver=btusb, 12M
        ID 8087:0025 Intel Corp. 
    |__ Port 3: Dev 3, If 1, Class=Wireless, Driver=btusb, 12M
        ID 8087:0025 Intel Corp. 
    ...
```

In this case, the vendor ID is 8087 and the product ID is 0025.

Then, use `usb_modeswitch` to reset the adapter:

```sh
usb_modeswitch -R -v <vendor ID> -p <product ID>
```
