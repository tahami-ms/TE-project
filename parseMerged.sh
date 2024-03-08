#!/usr/bin/env bash

file=$1
output=$2

# for every insertion in the merged.bed file
while read insertion
	do
		# we get the number of occurrences of "Target", overlapping TEs have several "Target"
		grepNumberTarget=$(echo "$insertion" | grep -o "Target" | wc -l)

		# if the number is equal or higher than 2 (ie, overlapping)
		if [[ "$grepNumberTarget" -ge 2 ]]; then
			info=$(echo "$insertion" | cut -f1-4)
			numbers=$(echo "$insertion" | cut -f5 | rev | cut -f1,2 -d' ' | rev)
			nFamily=$(echo "$insertion" | grep -o "\"Motif:\S*" | sort -u | wc -l)
			if [[ "$nFamily" -eq 1 ]]; then
				family=$(echo "$insertion" | grep -o "\"Motif:\S*" | sort -u)
				newAttribute="Target $family $numbers"
				echo -e "$info\t$newAttribute"
			# if there are several families annotated it will be either the "order's name", if it's the same for all families, or unknown
			else
				familyList=$(echo "$insertion" | grep -o "\"Motif:\S*" | sort -u | sed "s/\"Motif://g" | tr -d '"')
				orderInfo=$(while read family
					do
						order=$(awk -v family="$family" ' $1 == family ' TE_order.tab | cut -f2 )
						echo -e "$family\t$order"
					done <<< "$familyList" | sort -u)
				nOrder=$(echo "$orderInfo" | cut -f2 | sort -u | wc -l)
				if [[ "$nOrder" -eq 1 ]];then
					order=$(echo "$orderInfo" | head -n1 | cut -f2 )
					newAttribute="Target \"$order\" $numbers"
					echo -e "$info\t$newAttribute"
				else
					newAttribute="Target \"unknown\" $numbers"
					echo -e "$info\t$newAttribute"
				fi
			fi
		else
			echo "$insertion"
		fi
done < $file > $output