#!/bin/gawk -f

# this turns a json call log into a csv for easy digest.
# calls db is outgoing calls, call-log is incoming calls.

# timestamp is epoch in milliseconds, divide by 1000 and it works.

BEGIN{ FS=":"; printf("Timestamp,Phone Number,GeoCode,Duration,CallerId\n"); 
	tfmt=PROCINFO["strftime"];
}

/\{/ {
	dur=""; callNum=""; loc=""; dtStamp=""; caller="";
	while($0 !~ /\}/) {
	getline;
	if($1 ~ "duration") { dur=$2; sub(/,$/,"",dur); };
	if($1 ~ "number") { callNum=$2; sub(/,$/,"",callNum); };
	if($1 ~ "geocoded_location") { loc=$2; gsub(/,/,"",loc); };
	if($1 ~ "date") { dtStamp=$2; sub(/,$/,"",dtStamp); gsub(/"/,"",dtStamp); dtStamp=dtStamp/1000; dtStamp=strftime(tfmt, dtStamp);};
	if($1 ~ "display_name") { caller=$2; sub(/,$/,"",caller); };

	};

	printf("%s,%s,%s,%s,%s\n", dtStamp, callNum, loc, dur, caller);
};
