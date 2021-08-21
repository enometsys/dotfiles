# GPGKey generation, usage, and maintenance

#### File extensions

- `.gpg` GNU Privacy Guard public keyring file, binary format.
- `.sig` GPG signed document file, binary format.
- `.asc` ASCII-armored signature with or without wrapped document, plain text format

#### Livedisk

A livedisk must be used in an air-gapped environment to generate new keys (or any operation that requires the use of the primary key)

use [archiso](https://wiki.archlinux.org/title/Archiso) with the ff packages preinstalled
- gnupg
- hopenpgp-tools
- libusb-compat
- ccid
- pcsc-tools
- tar
- tmux
- neovim
- yubikey-personalization
- yubikey-manager
- qrencode
- viu
- zbar

`gpg.conf` for livedisk (where the keys will be generated)

```
# gpg.conf
no-emit-version
no-comments
keyid-format 0xlong
with-fingerprint
list-options show-uid-validity
verify-options show-uid-validity
use-agent
charset utf-8
personal-cipher-preferences AES256 AES192 AES CAST5
personal-digest-preferences SHA512 SHA384 SHA256 SHA224
cert-digest-algo SHA512
default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
compress-algo ZLIB
disable-cipher-algo 3DES
weak-digest SHA1
cipher-algo AES256
digest-algo SHA512
cert-digest-algo SHA512
s2k-cipher-algo AES256
s2k-digest-algo SHA512
s2k-mode 3
s2k-count 65011712
```

##### Generate keys

```sh
# Create temporary $GNUPGHOME dir
$ export GNUPGHOME=$(mktemp -d);

# Create gpg master key
# - cert capability only
# - ECC curve25519 (ed25519) algo
# - 1year expiration
$ gpg --expert --full-generate-key

# Save gpg keyid
$ KEYID=<id shown in the previous step>

# Create ESA (Encrypt, Sign, and Authenticate) subkeys
# - ECC curve25519 with specific capabilities
# - 1year expiration each
# Usage:
# - encryption (pass, encrypt/decrypt files)
# - sign (git commits, sign files)
# - auth (ssh)
$ gpg --expert --edit-key $KEYID
gpg> addkey
gpg> addkey
gpg> addkey
gpg> save

# Check best practice
$ gpg --export $KEYID | hokey lint
```

##### Backup keys

```sh
$ export EXPORTS=$(mktemp -d);
$ export SECRETS=$(mktemp -d);

# Create revocation certificate
$ gpg --gen-revoke $KEYID > $SECRETS/$KEYID.revoke.asc

# Export keys
$ gpg --armor --export $KEYID > $EXPORTS/$KEYID.pub.asc
$ gpg --armor --export-secret-keys $KEYID > $SECRETS/$KEYID.priv.asc
$ gpg --armor --export-secret-subkeys $KEYID > $SECRETS/$KEYID.privsubs.asc

## Generate QRCode for revocation, priv, and privsubs
#./asc2qr --out-dir $SECRETS --prefix $KEYID.revoke.QR $SECRETS/$KEYID.revoke.asc
#./asc2qr --out-dir $SECRETS --prefix $KEYID.priv.QR $SECRETS/$KEYID.priv.asc
#./asc2qr --out-dir $SECRETS --prefix $KEYID.privsubs.QR $SECRETS/$KEYID.privsubs.asc

# Secret should show as `sec#` to indicate that the secret 
# part of the master key doesn't exist in the keyring
$ gpg -K

# Compress and encrypt backup files
# NOTE: important that encryption here be symmetric as
# encrypting it assymmetrically using generated secret keys
# is like locking the keys in the vault. it can't be opened
# in a new machine w/o access to the secret keys (w/c would making the backup useless)
$ tar -C $SECRETS -cz . | gpg --symmetric --cipher-algo AES256 > $KEYID.secrets.tgz.gpg
# Decrypt and uncompress
$ gpg --decrypt < $KEYID.secrets.tgz.gpg | tar xz

# Mount your encrypted vault to /mnt/vault
$ cryptsetup luksOpen /dev/sdXN vault
$ mkdir /mnt/vault
$ mount /dev/mapper/vault /mnt/vault
$ mkdir /mnt/vault/gpg-backups

# Copy the files
$ cp -a $KEYID.secrets.tgz.gpg /mnt/vault/gpg-backups
$ cp -a $EXPORTS/* /mnt/vault/gpg-backups

# Umount your encrypted vault
$ sudo umount /mnt/vault
$ sudo cryptsetup luksClose vault
```

##### Transfer tO SC (Smartcards e.g. yubikey)

###### Make sure pcscd and gpg-agent services are running.

```sh
$ systemctl start pcscd
```

###### Change PINs and Set some info (for new SC/SK)

Factory defaults are 123456 for normal user and 12345678 for admin user.

```sh

$ gpg --card-edit
gpg/card> admin
# [kdf-setup](https://developers.yubico.com/PGP/YubiKey_5.2.3_Enhancements_to_OpenPGP_3.4.html) prevents plain text PIN from being sent over USB
gpg/card> kdf-setup
# first change Admin PIN (3), then change PIN (1)
# Note that PIN does not have to be numeric
gpg/card> passwd

# Set some information
gpg/card> name
gpg/card> login
gpg/card> lang
gpg/card> sex
gpg/card> quit
```

###### Move the keys into the card

```sh
$ gpg --expert --edit-key $KEYID
gpg> toggle
gpg> key 1
gpg> keytocard
Your selection? 1

gpg> key 1
gpg> key 2
gpg> keytocard
Your selection? 2

gpg> key 2
gpg> key 3
gpg> keytocard
Your selection? 3

gpg> save
```

###### Touch policy for the yubikey can be configured as follows

```sh
$ ykman openpgp set-touch SIG FIXED
$ ykman openpgp set-touch ENC FIXED
$ ykman openpgp set-touch AUT FIXED
```

###### Verify that the keys were moved. Now they should be marked as ssd> indicating they are stubs for a smartcard key.

```sh
$ gpg --list-secret-keys
```

##### Cleanup

Remove secret key in keyring

```sh
$ gpg --delete-secret-key $KEYID
```
