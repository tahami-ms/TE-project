#!/bin/bash


TElist=$(<$1)

for TEconsensus in $TElist
	do
		insertionsTEcons=$(awk -v var=${TEconsensus} '$4 == var' "filename.bed")
		counter=0
		while read insertion
		do
			insertionStrand=$(echo  "$insertion" | cut -f6) 
			
			if [[ $insertionStrand == "+" ]]; then
				leftSequence=$(echo "$insertion" | cut -f14)
                                startTE=$(echo "$insertion" | cut -f12 )
			elif [[ $insertionStrand == "-" ]]; then
				leftSequence=$(echo  "$insertion" | cut -f12)
                                startTE=$(echo "$insertion" | cut -f14 )
			fi

			if [ $leftSequence -lt 10 -a $startTE -lt 10 ]; then
			 	counter=$(( counter + 1 ))
			fi 
		done <<< "$insertionsTEcons"
		
		echo $TEconsensus $counter

		if [[ $counter -ge 2 ]]; then
			echo "$insertionsTEcons" >> fullLength.tsv
		fi


	done
