
## NOTE: On Ubuntu 14.x or newer, use "remake" to run this Makefile
##   alias make=remake
.ONESHELL:

bin/ansible:
	virtualenv --python=/usr/bin/python2 .
	bin/pip install --upgrade pip
	bin/pip install -r requirements.txt

create_lxc:
	sudo lxc-create -n devstack -t ubuntu -f devstack-lxc.conf -- --packages=bsdmainutils,git,python-apt

start_lxc:
	sudo lxc-ls | egrep devstack || exit 1	## do we have a container?
	sudo lxc-start -n devstack --daemon --logfile=devstack-run.$$$$.log
	echo `lxc-info -n devstack --ips | awk '/IP:/ { print $$2 }'`

BOOTS_ENV="ansible_ssh_user=ubuntu  ansible_ssh_pass=ubuntu ask_sudo_pass=True"
boots_lxc: start_lxc
	HOST=`lxc-info -n devstack --ips | awk '/IP:/ { print $$2 }'`
	bin/ansible-playbook -vv -e ${BOOTS_ENV} lxc-setup.yml 

stop_lxc:
	sudo lxc-stop -n devstack

run_playbook: bin/ansible
#	SERVER_IP=`lxc-info -n devstack --ips | awk '/IP:/ { print $$2 }'`
	test -f ./customize.yml || exit 1  ## did we customize DevStack (run)?
	bin/ansible-playbook -vv -i hosts.ini  site.yml

real_clean:
	/bin/rm -rf bin lib include
