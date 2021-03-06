#!/bin/bash

while true; do
	git reset --hard	#
	git pull origin master	# Make sure the local copy is up-to-date
	./migrate.sh		#

	subscripts=()
		
	if [ -z "$githubToken" ]				# Make sure the
								# githubToken env var is set
	then							# and if it's not ask the
		echo "Missing GitHub token, please enter it: "  # user to enter it and set
		read githubToken				# it as an env var
		export githubToken=$githubToken
	fi

	./updater/run.sh &	# Run the updater (in the background)
	subscripts+=$!		# and push its PID to subscripts

	trap "kill ${subscripts[*]}" SIGINT	# Kill all subscripts on SIGINT (^C)
	wait					# Wait for all subscripts to die
	trap - SIGINT				# Remove the SIGINT kill trigger

	for second in {10..1}
	do
		echo -ne "Restarting in $second seconds..\r"
		sleep 1
	done

done
