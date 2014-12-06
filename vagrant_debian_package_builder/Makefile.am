# Requires the use of Vagrant and reasonable bandwidth/time.
#
#This makefile was designed for:
#
# 1. prepare-pristine-building-environment - 	This rule prepares a Debian Unstable package building
#						machine as a vagrant VM. It can do this from scratch
#						or from several check-points in that process.
#
#						It is essential to run it, before any sort of package
#						creation tasks are undertaken.
#
# 2. prepare-new-package-for-building -		This rule assumes that you have run the first rule.
#						It also assumes that you have you Debian Alioth account
#						setup.
#						It is intended to set up a completely new package
#						building structure in order to create a new Debian package.
#
# 3. prepare-snp-sites-package-for-building -	This rule assumes that you have run the first rule.
#						It is intended to set up the snp-sites package building
#						structure in order to update the package when a new release
#						is available.
#
#						It should not be used to setting up a completely new package.
#
# 4. prepare-fastaq-package-for-building -	This rule assumes that you have run the first rule.
#						It is intended to set up the fastaq package building
#						structure in order to update the package when a new
#						release is available.
#
#						It should not be used to setting up a completely new package.
#
# 5. prepare-kmc-package-for-building -		This rule assumes that you have run the first rule.
#						It is intended to set up the kmc package building
#						structure in order to update the package when a new
#						release is available.
#
#						It should not be used to setting up a completely new package.
#
# 6. prepare-iva-package-for-building -		This rule assumes that you have run the first rule.
#						It is intended to set up the iva package building
#						structure in order to update the package when a new
#						release is available.
#
#						It should not be used to setting up a completely new package.
#
#
# To build the packages themselves I prefer to actually login to the Debian VM
#  and do all the editing of the debian files there.
#
# Main reason for this is that it is a very interactive process and several
# runs of git-pbuilder will be done until the packager gets it right.
#
# If the upstream code needs to be patched for some reason, you need to use
# quilt to keep track of the patches.
#
# Once the package builds, you need to run lintian on the .deb file to do
# quality control of the package. Generally the packge won't be lintian clean
# at first build. The process og git-pbuilder starts again.

VAGRANT_HOME=/vagrant
SETUP_HOME=${VAGRANT_HOME}/package_builder_setup

BASE_PBUILDER_DIR=/var/cache/pbuilder
HOOK_DIR= ${BASE_PBUILDER_DIR}/hook.d
REPO_DIR=${BASE_PBUILDER_DIR}/repo
BASE_TGZ_DIR=${BASE_PBUILDER_DIR}/base-sid-amd64.cow

HOOKS=/usr/lib/pbuilder/hooks
MAIN_PBRC=/etc/pbuilderrc
ROOT_PBRC=/root/.pbuilderrc
HOME_PBRC=~/.pbuilderrc

NEW_PROJECT_GIT=automated-vagrant-build.git
NEW_PROJECT_DIR=${VAGRANT_HOME}/automated-vagrant-build
DEBIAN_DIR=${VAGRANT_HOME}/debian
USER_EMAIL='j.s.soares@gmail.com'
USER_NAME='Jorge Soares'


prepare-pristine-building-environment:
	vagrant up
	vagrant provision
	vagrant ssh -c "if [ ! -e ~/.bash_aliases ]; then echo 'export LANG=en_GB.UTF-8 && export LANGUAGE=en_GB.UTF-8;' >> ~/.bash_aliases; fi"
	vagrant ssh -c "sudo cp ${SETUP_HOME}/sources.list /etc/apt/"
	vagrant ssh -c "sudo apt-get update"
	vagrant reload
	vagrant ssh -c "sudo apt-get install build-essential"
	vagrant ssh -c 'locale_list=$$(locale -a); if [[ ! $$locale_list =~ en_GB.utf8 ]]; then sudo dpkg-reconfigure locales; fi'
	vagrant ssh -c "sudo apt-get update"
	vagrant ssh -c "sudo apt-get upgrade"
	vagrant ssh -c "sudo apt-get autoremove"
	vagrant reload
	vagrant ssh -c "sudo apt-get install apt-cacher-ng git subversion dh-autoreconf libtool autopoint debhelper lintian pbuilder git-buildpackage piuparts asciidoc help2man cowbuilder quilt"
	vagrant ssh -c "if [ ! -d ${HOOKS} ]; then sudo mkdir ${HOOKS}; fi && if [ ! -d ${REPO_DIR} ]; then sudo mkdir ${REPO_DIR}; fi && sudo chmod 777 ${REPO_DIR}"
	vagrant ssh -c "if [ ! -e ${SETUP_HOME}/D05deps ]; then sudo cp ${SETUP_HOME}/D05deps ${HOOKS} && sudo chmod +x ${HOOKS}/D05deps; fi"
	vagrant ssh -c "if [ ! -e ${SETUP_HOME}/root_pbuilderrc ]; then sudo cp ${SETUP_HOME}/root_pbuilderrc ${MAIN_PBRC}; fi"
	vagrant ssh -c "if [ ! -e ${SETUP_HOME}/home_pbuilderrc ]; then sudo cp ${SETUP_HOME}/home_pbuilderrc ${ROOT_PBRC}; fi"
	vagrant ssh -c "if [ ! -e ${SETUP_HOME}/home_pbuilderrc ]; then cp ${SETUP_HOME}/home_pbuilderrc ${HOME_PBRC}; fi"
	vagrant ssh -c "sudo dpkg-scanpackages ${REPO_DIR} > ${REPO_DIR}/Packages"
	vagrant ssh -c "if [ ! -d ${BASE_TGZ_DIR} ]; then sudo DIST=sid ARCH=amd64 git-pbuilder create; fi"
	vagrant ssh -c "sudo DIST=sid ARCH=amd64 git-pbuilder update"	
	vagrant ssh -c "if [ ! -d ${HOOK_DIR} ]; then sudo mkdir ${HOOK_DIR}; fi"
	vagrant ssh -c "if [ ! -e ${HOOK_DIR}/C10shell ]; then sudo cp ${SETUP_HOME}/C10shell ${HOOK_DIR} && sudo chmod a+x ${HOOK_DIR}/C10shell; fi"
	vagrant halt


#Once in the debian git machine, you need ot run these manually
#umask 002 && cd /git/debian-med
#mkdir ${NEW_PROJECT_GIT} && cd ${NEW_PROJECT_GIT} && git --bare init --shared && exit

prepare-new-package-for-building: setup-debian-git
	vagrant ssh -c "git config --global user.email ${USER_EMAIL} && git config --global user.name ${USER_NAME}"
	vagrant ssh -c "cd ${VAGRANT_HOME} && git clone ssh://git.debian.org/git/debian-med/${NEW_PROJECT_GIT}"
	vagrant ssh -c "cp -r ${DEBIAN_DIR} ${NEW_PROJECT_DIR}"
	vagrant ssh -c "cd ${NEW_PROJECT_DIR} && git add debian/ && git commit -m 'initial commit' && git push --all"
	vagrant halt

setup-debian-git:
	vagrant up
	vagrant ssh -c "cp ${SETUP_HOME}/ssh_js21/* .ssh/"
	vagrant ssh -c "ssh jssoares-guest@git.debian.org"

prepare-snp-sites-package-for-building:
	vagrant up


	vagrant halt


prepare-fastaq-package-for-building:
	vagrant up


	vagrant halt

prepare-kmc-package-for-building:
	vagrant up


	vagrant halt

prepare-iva-package-for-building:
	vagrant up


	vagrant halt

