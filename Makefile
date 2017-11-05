.PHONY: github photo photo_mount photo_sync photo_umount clean

SMB_PW = $(shell security find-internet-password -ga $${USER} -w -s KEVIN._smb._tcp.local)
TMP_DIR = $(shell echo $${TMPDIR}/home-kevin)
MY_DIR= $(shell echo $${PWD})

all: github pocket photo

github: pull_all_repos_from_org.sh
	cd ~/Documents/src/; $(MY_DIR)/$< user lukaspustina
	cd ~/Documents/Work/CD/src; $(MY_DIR)/$< org centerdevice
	cd ~/Documents/Work/CC; $(MY_DIR)/$< org codecentric private
	cd ~/Documents/Work/Rheinwerk; $(MY_DIR)/$< org rheinwerk public

pocket:
	echo Deleting all articels older than 4 weeks
	rat pocket delete $$(rat -q pocket list --until 4w --output id | grep -v 'Rece' | tr -d '*: ' | paste -s -d ' ' -)

photo: photo_mount photo_sync photo_umount

photo_mount:
	mkdir -p $(TMP_DIR)
	mount_smbfs //lukas:$(SMB_PW)@kevin/home $(TMP_DIR)

photo_sync: $(TMP_DIR)
	-rsync -avz ~/Pictures/Photos\ Library.photoslibrary Library $(TMP_DIR)

photo_umount:
	-umount $(TMP_DIR)
	-rmdir $(TMP_DIR)

clean: photo_umount

