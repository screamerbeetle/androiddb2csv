#!/bin/nawk -f

# this strips names and numbers from android's contacts db and prints in orgmode.
# we leave any extra information alone, as that's more useful for the call log.

BEGIN { FS=":";}; 

/"phonenumber"/ {
	# phone numbers
	dNum=""; eMail="";
	numbers=$2; 
	gsub(/[ \\\"]/, "", numbers); 
	n=split(numbers,nums,","); 
	# split on comma, drop last entry...
	for(i=1;i<n;i++) { dNum=dNum sprintf("tel:%s\n", nums[i]);};
	# display name
	getline;
	while($1 !~ /"display_name"/) { getline; };
	#print $2;
	dispName=$2;
	gsub(/[\\\"]/, "", dispName); 
	sub(/,$/, "", dispName);
	# email address
	getline;
	while($1 !~ /"data1"/) { getline; };
	if($2 ~ /@/) { eMail=$2; };
	sub(/^ /, "", eMail);
	sub(/^"/, "", eMail);
	sub(/,$/, "", eMail);
	sub(/"$/, "", eMail);

	# printout
	printf("* %s\n\n%s\n", dispName, dNum);
	if(eMail ~ /\@/) {printf("mailto:%s\n\n", eMail);};
	};
