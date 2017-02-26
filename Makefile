.PHONY: github photo photo_mount photo_sync photo_umount clean

SMB_PW = $(shell security find-internet-password -ga $${USER} -w -s KEVIN._smb._tcp.local)
TMP_DIR = $(shell echo $${TMPDIR}/home-kevin)
MY_DIR= $(shell echo $${PWD})


all: github photo


github: pull_all_repos_from_org.sh
	cd ~/Documents/src/; $(MY_DIR)/$< user lukaspustina
	cd ~/Documents/Work/CD/src; $(MY_DIR)/$< org centerdevice
	cd ~/Documents/Work/CC; $(MY_DIR)/$< org codecentric private

photo: photo_mount photo_sync photo_umount

photo_mount:
	mkdir -p $(TMP_DIR)
	mount_smbfs //lukas:$(SMB_PW)@kevin/home $(TMP_DIR)

photo_sync: $(TMP_DIR)
	rsync -avz ~/Pictures/Photos\ Library.photoslibrary Library $(TMP_DIR)

photo_umount:
	-umount $(TMP_DIR)
	-rmdir $(TMP_DIR)

clean: photo_umount

