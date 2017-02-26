.PHONY: github photo photo_mount photo_sync photo_umount

SMB_PW = $(shell security find-internet-password -ga $${USER} -w -s KEVIN._smb._tcp.local)
TMP_DIR = $(shell echo $${TMPDIR}/home-kevin)


all: github photo


github: ~/bin/backup_github.sh
	$<

photo: photo_mount photo_sync photo_umount

photo_mount:
	mkdir -p $(TMP_DIR)
	mount_smbfs //lukas:$(SMB_PW)@kevin/home $(TMP_DIR)

photo_sync:
	(cd $(TMP_DIR); ./rsync_photos.sh)

photo_umount:
	umount $(TMP_DIR)
	rmdir $(TMP_DIR)

