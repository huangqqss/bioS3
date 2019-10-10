#!/bin/bash
#	geneDocUpdate.sh - Merge and update downloaded geneDocSum
# DESCRIPTION
#	NCBI Entrez Gene is a huge database and updating.  The FTP site
#	provides `geneDocSum.pl` for extracting data using E-utilities, like
#		ftp://ftp.ncbi.nih.gov/gene/tools/geneDocSum.pl \
#		      	-v -q '"Homo sapiens"[Organism]' -o tab \
#		      	-t Name -t Description -t CurrentID -t Summary
#	The downloading is usually interrupted (by the poor network).
#	The data should be downloaned multiple times, updated, and merged.
# USAGE
#	cat gene.old | ./geneDocSum.pl gene.update >gene.new

mapfile -t < <(grep '^[0-9]' "$1" | sort --numeric-sort)
# `grep|mapfile` makes mapfile work in a subshell and discard MAPFILE
declare -i I=0
while
	IFS='	' read -r ID GENE
do
	[[ "$ID" =~ ^[0-9]+ ]] || { echo "$ID	$GENE" ; continue; }
	[[ $I -ge ${#MAPFILE[@]} ]] && {
		echo "$ID	$GENE"
		break
	}
	IDNEW="${MAPFILE[$I]%%	*}"
	if [[ "$ID" -eq "$IDNEW" ]]
	then
		echo "${MAPFILE[$I]}"
		let I++
	elif [[ "$ID" -lt "$IDNEW" ]]
	then
		echo "$ID	$GENE"
	else
		while [[ "$ID" -ge "$IDNEW" ]]
		do
			echo "${MAPFILE[$I]}"
			let I++
			[[ $I -ge ${#MAPFILE[@]} ]] && break
			IDNEW="${MAPFILE[$I]%%	*}"
		done
		if [[ "$ID" -lt "$IDNEW" ]]
		then
			echo "$ID	$GENE"
		fi
	fi
done
cat	# the remaining input
while [[ $I -lt ${#MAPFILE[@]} ]]
do
	echo "${MAPFILE[$I]}"
	let I++
done
