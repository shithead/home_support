
SSHCMD="`which ssh`"
SSHREMOTEPORT=""
SSHUSER="player"
SSHDCMD="`which sshd`"
SSHDPORT=""
SSHDKEYFILE="${HOME}/.ssh/support-$(hostname)-$(whoami)"
SSHDPIDFILE="/var/run/sshd-$(hostname)-$(whoami).pid"

AUTHORIZEDKEYFILE="${HOME}/.ssh/authorized_key"

SUPPORTERADDR=""
SUPPORTERSSHDPORT=""
# the public key needs the word supporterkey in the comment.
export SUPPORTERPUBLICKEY=" supporterkey"

if [ -x support.conf ]
then
	. support.conf
fi

create_keyfile () {
	SSHKEYGENCMD="`which ssh-keygen`"
	${SSHKEYGENCMD} -N "" -t ed25519 -f ${SSHDKEYFILE}
	cat ${SSHDKEYFILE}.pub
}

authoriz_supporter () {
	sudo "
		mkdir ${HOME}/.ssh
		echo -e ${SUPPORTERPUBLICKEY} >> ${HOME}/.ssh/authorized_key
	"
}

start_sshd () {
	${SSHDCMD} -o "Port ${SSHDPORT}" -o "PidFile ${SSHDPIDFILE}" -o "PermitRootLogin yes"
}

stop_sshd () {
	 cat ${SSHDPIDFILE} | kill -9
}

establish_tunnel () {
	${SSHCMD} -R ${SSHREMOTEPORT}:localhost:${SSHDPORT} -i ${SSHDKEYFILE}  ${SSHUSER}@${SUPPORTERADDR} -p${SUPPORTERSSHDPORT}
}

main () {
	if [ ! -x ${SSHDKEYFILE} ]
	then
		echo -e "Create Keyfile"
		create_keyfile
		echo -e "Send the public key to your supporter."
		return
	fi
	if [ ! grep -q supporterkey ${AUTHORIZEDKEYFILE} ]
	then
		echo -e "Authoriz Supporter"
		authoriz_supporter
	fi
	start_sshd
	establish_tunnel
}

main()
stop_sshd
