#!/bin/bash
#  
# Test the efficiency of "http-api" using "wget"
# 
# A simple "bash" script that forks multiple "processes" that each accesses an "http-api",  
# for example a web site, and prints out the total time taken for all requests to complete. 
# Note that it uses a "urls-file" (text), which contains a list of "urls" that we want 
# each "wget" process to access.
#
# "wget" is essentially being used as a "quick and dirty" tool for loading the "http-api" 
# in order to test and monitor its performance.
#
# An example of a "urls-file" can be found below. It contains "http" (get) requests to an 
# "http api" of an "sms" gateway - one "http" (get) request per line - processing data 
# concerning the transmission of a message, such as the destination (da) and originating (oa) 
# addresses of (mt) "sms", their message body (txt), a flag (reg) enabling or not the request 
# for "delivery report" (dlr) as well as "fallback url" handing any "incoming" events, 
# e.g. "smsc-ack" or "dlr" messages and a "message-id" (mintid) :
# http://localhost:8080/httpapi?da=+0000000001&oa=1234&mintid=msgid_0001&reg=true&eventUrl=http://localhost:8080&txt=stress_test_message_0001
# http://localhost:8080/httpapi?da=+0000000002&oa=1234&mintid=msgid_0002&reg=true&eventUrl=http://localhost:8080&txt=stress_test_message_0002
# http://localhost:8080/httpapi?da=+0000000003&oa=1234&mintid=msgid_0003&reg=true&eventUrl=http://localhost:8080&txt=stress_test_message_0003
#
# Script's (core) source code found at https://blogs.oracle.com/unixcoach/entry/using_wget_to_test_the
# Updated with (line by line) comments and several changes by Aristotelis Metsinis.
#

# If necessary specify the "username" and "password" for the "http" request(s); the "http-api" of the 
# "sms" gateway may require some basic authentication.
USERNAME="username"
PASSWORD="password"

# Set fonts for help.
NORM=$(tput sgr0)
BOLD=$(tput bold)

# Store script's name with any leading directory components removed. 
script=$(basename $0)
# Store script's directory, stripping the last part of the given file name; in effect outputting just the 
# directory components of the pathname.
dir=$(dirname $0)
# Store logging directory; a subdirectory of script's dir.
logs="$dir/"logs

# Script expects two input command line arguments: the number of "wget" processes and the (text) "urls-file".
if [[ $# < 2 ]]; then  
	echo
    echo "${BOLD}Usage${NORM}   : ./$script <#processes> <urls-file>" 
	echo "${BOLD}Example${NORM} : ./$script 100 urls_file.txt"  
	echo
    exit 1
fi

# Check whether the given "urls-file" does not exist.
if [ ! -f $2 ]; then 
	echo
	echo "${BOLD}Error${NORM} : \"$2\" no such file."
	echo
	exit 1
fi

# Store system's time and date in a "YYYY-MM-DD HH:MM:SS.MS" format; script's start-up timestamp.
start=$(date '+%F %T.%3N')
# Store script's start-up timestamp in a "YYYYMMDD_HHMMSS" format.
timestamp=$(date '+%Y%m%d_%H%M%S')

# Initiate as many "wget" commands as those defined by the "first" input command line argument;
# each "wget" command shall run in the background.
for ((i=1; i<=$1; i++)) 
do 
  # * Read "urls" from the file defined by the "second" input command line argument.
  # * Don't set the local file's timestamp by the one on the server.
  # * Log all messages (normally reported to "standard error") to "<script>_YYMMDD_HHMMSS.log" file.
  #   Actually, each "wget" process will append data to that log file instead of overwriting the old log file. 
  #   If log file does not exist, a new file shall be created.   
  # * Concatenate together and write all "http-api" responses (documents) - to "output_YYMMDD_HHMMSS.log" file. 
  #   Actually, responses will be printed to "standard output" and shall then be (shell) redirected (appended) 
  #   to that log file.  
  # * Note: we could possibly write the files to "/dev/null" to remove any possible "I/O" overhead.
  # * If necessary specify the "username" and "password" for the "http" request(s); the "http-api" of the 
  #   "sms" gateway may require some basic authentication.
  wget --no-use-server-timestamps -a "$logs"/"${script%.*}"_"$timestamp".log -O - -i "$2" --user="$USERNAME" --password="$PASSWORD" >>"$logs"/output_"$timestamp".log 2>>"$logs"/error_"$timestamp".log &  
done 

# Wait for all currently active child "processes" to finish.
wait 

# Store system's time and date in a "YYYY-MM-DD HH:MM:SS.MS" format; script's completion timestamp.
end=$(date '+%F %T.%3N')

# Store the total time taken for all requests to complete. 
total=$(date -u -d "0 $(date -u -d "$end" +"%s.%N") sec - $(date -u -d "$start" +"%s.%N") sec" +"%H:%M:%S.%3N")           

echo
# Print out the "host name" of the loading machine, the input "urls-file", the number of "wget" processes executed 
# the script's start-up and completion timestamps as well as the total execution time. In addition, fetch and print
# some information about the (http) requests submitted by each of the "wget" commands.
echo "${BOLD}hostname${NORM}  : $(hostname)"
echo "${BOLD}file${NORM}      : $2"
echo "${BOLD}threads${NORM}   : $1"
echo "${BOLD}start time${NORM}: $start"
echo "${BOLD}end time${NORM}  : $end"
echo "${BOLD}total time${NORM}: $(printf "%23s\n" "$total")"
echo
echo "$(GREP_COLORS='mt=01' grep --color=always "Downloaded:" "$logs"/"${script%.*}"_"$timestamp".log)"
echo

exit 0
