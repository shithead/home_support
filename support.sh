
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

if [ -e support.conf ]
then
	. support.conf
fi

create_keyfile () {
	SSHKEYGENCMD="`which ssh-keygen`"
	${SSHKEYGENCMD} -N "" -t ed25519 -f ${SSHDKEYFILE}
	cat ${SSHDKEYFILE}.pub
}

authoriz_supporter () {
	sudo 	mkdir ${HOME}/.ssh 2>/dev/null; \
		echo -e ${SUPPORTERPUBLICKEY} >> ${HOME}/.ssh/authorized_key
}

start_sshd () {
	${SSHDCMD} -o "Port ${SSHDPORT}" -o "PidFile ${SSHDPIDFILE}" -o "PermitRootLogin yes"
}

stop_sshd () {
	 kill -n 9 $(cat ${SSHDPIDFILE})
	 rm ${SSHDPIDFILE}
}

establish_tunnel () {
	${SSHCMD} -N -R ${SSHREMOTEPORT}:localhost:${SSHDPORT} -i ${SSHDKEYFILE}  ${SSHUSER}@${SUPPORTERADDR} -p${SUPPORTERSSHDPORT}
}

main () {
	if [ ! -e ${SSHDKEYFILE} ]
	then
		echo -e "Create Keyfile"
		create_keyfile
		echo -e "Send the public key to your supporter."
		return
	fi
	grep -q supporterkey ${AUTHORIZEDKEYFILE}
	if [ 0 -ne $? ]
	then
		echo -e "Authoriz Supporter"
		authoriz_supporter
	fi
	start_sshd
	establish_tunnel
}

main
if [ -e ${SSHDPIDFILE} ]
then
	stop_sshd
fi
