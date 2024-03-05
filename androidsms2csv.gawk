#!/bin/gawk -f

# this parses the message logs from the phone into csv for easy reading.
# this uses the borked json format that android provides, but might work for other cases.

BEGIN{ tfmt=PROCINFO["strftime"]; }

function strip(outPut) {
	dq=index(outPut,":");
	outPut=substr(outPut,dq+2);
	return outPut;
}

{
	mult=1; dRec=""; sDate=""; sAddr=""; addr=""; threadID=""; dispName=""; tBody=""; mmsText=""; rAddr="";
	line=$0; gsub(/","/,"\n",line);
	if(line ~ /mms=true/) { mms="yup"; mult=1;};
	n=split(line,terms,"\n");
	for(each=1;each<=n;each++) {
		#print terms[each];
		#matchops forever!
		if(terms[each] ~ /^\{"_id":"/) { ident=terms[each];
	ident=strip(ident);
	 #print ident;
	 };
		if(terms[each] ~ /thread_id":"/) { threadID=terms[each];
	threadID=strip(threadID);
	 #print threadID;
	 };
		if(terms[each] ~ /__sender_address/) {
	 sAddr=terms[(each+2)];
	 sAddr=strip(sAddr);
	 sAddr=substr(sAddr,1,length(sAddr));
	 if(terms[(each+5)] ~ /__display_name/) { 
	  scratch=terms[(each+5)];
	  scratch=strip(scratch);
	  sub(/"/,"\n",scratch);
	  idx=index(scratch,"\n");
	  scratch=substr(scratch,1,idx-1);
	  sAddr=sAddr ";" scratch;
	  };
	 };
		if(terms[each] ~ /__recipient_address/) {
			loop=2;
			while(terms[(each+loop)] ~ /address/) {
	    scratch=terms[(each+loop)];
	    scratch=strip(scratch);
	      if(rAddr!="") { rAddr=rAddr "::" scratch; } else { rAddr=scratch; };
	      if(terms[(each+loop+3)] ~ /__display_name/) { 
		loop=loop+3;
	        scratch=terms[(each+loop)];
	        scratch=strip(scratch);
	        sub(/"/,"\n",scratch);
	        idx=index(scratch,"\n");
	        scratch=substr(scratch,1,idx-1);
	        rAddr=rAddr ";" scratch;
	    };
			loop+=2;
			};
			#print rAddr;
	 };
		if(terms[each] ~ /address/) { 
			addr=terms[each];
			addr=strip(addr);
			addr=substr(addr,1,length(addr));
			if(terms[n] ~ /__display_name/) {
				scratch=strip(terms[n]);
				addr=addr ";" substr(scratch,1,length(scratch)-2);
				};
			#print addr;
			if(sAddr==""){ sAddr=addr; };
	 };
		if(terms[each] ~ /date":"/) { dRec=terms[each];
	 		#print dRec; 
	 		dRec=strip(dRec); 
			dRec=dRec+0;
			#print dRec;	
			if(dRec>10e9){ mult=1000; }; 
	 		dRec=dRec/mult; dRec=strftime(tfmt, dRec); 
	 };
		if(terms[each] ~ /date_sent":"/) { sDate=terms[each];
	 		#print sDate;
	 		sDate=strip(sDate); sDate=sDate+0;
			#print sDate;
			if(sDate>10e9){ mult=1000; }; 
	 		sDate=sDate/mult; sDate=strftime(tfmt, sDate); 
	 };
		if(terms[each] ~ /body":"/) { tBody=terms[each];
			tBody=strip(tBody);
			if(mmsText=="") { mmsText=tBody; };
	 		#print tBody;
	 };
		if(terms[each] ~ /text":"/) { mmsText=terms[each];
			mmsText=strip(mmsText); mmsText=substr(mmsText,1,length(mmsText)-4);
	 		#print mmsText;
			#if(tBody=="") { tBody=mmsText; };
	 };
		if(terms[each] ~ /_data":"/) { mmsData=terms[each];
#print mmsData;
	 };

	}; #end main for loop

	#printit
	printf("%s,%s,%s,%s,%s,%s\n", dRec, ident, threadID, sAddr, dispName, mmsText );

};
