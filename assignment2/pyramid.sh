#!/bin/bash

# pyramid: program som skriver ut pyramide basert på brukerinput

size=0

if [[ $# == 1 && $1 =~ ^[1-9]$ ]]; then
	size=$1
else
	until [[ $size =~ ^[1-9]$ ]]; do
		read -p "Hvor stor (1-9)? " size
		if [[ ! $size =~ ^[1-9]$ ]]; then
			echo "Ugyldig verdi! Prøv igjen."
			echo
		fi
	done
fi

for (( i=1; i<=size; i++ )); do
	for (( j=1; j<=((size-i)); j++ )); do
		echo -n " "
	done
	for (( j=1; j<=i; j++ )); do
		echo -n "$i "
	done
	echo
done
