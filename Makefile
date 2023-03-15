all: update check setup

update:
	git pull

check:
	shellcheck -o all setup.sh

setup:
	sudo bash setup.sh
