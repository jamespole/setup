all: update check setup

update:
	git pull

check:
	shellcheck setup.sh

setup:
	sudo sh setup.sh
