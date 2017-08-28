# SUPPORT YOUR FAMILY

This script helps you to support your family remote.

## Requierments

* openssh-server
* connectable server under your control

## Usage

1. Edit support.sh or create a file support.conf and set variables

* SSHUSER - user for family to connect on supporter sshdeamon
* SSHDPORT - listen port of family sshdeamon
* SUPPORTERADDR - supporter addresse, can be ip address or domain
* SUPPORTERSSHDPORT - listen port of supporters sshdeamon
* SUPPORTERREMOTESSHPORT - bind to remote port, where the supporter connect on
* SUPPORTERPUBLICKEY - public ssh key of support (comment need the string "supporterkey")

2. Send script your family.
3. Run script and get publickey from your family.
4. Run again.
If your family has establish the tunnel the support can use the SUPPORTERREMOTESSHPORT on the server (SUPPORTERADDR) to connect on sshdeamon (listen on SSHDPORT) on family computer.

	ssh -p ${SUPPORTERREMOTESSHPORT} -i ${SUPPORTER_PRIVATE_KEY} root@localhost
