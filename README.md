 
#Test the efficiency of "http-api" using "wget"

A simple "bash" script that forks multiple "processes" that each accesses an "http-api", for example a web site, and prints out the total time taken for all requests to complete. Note that it uses a "urls-file" (text), which contains a list of "urls" that we want 
each "wget" process to access.

"wget" is essentially being used as a "quick and dirty" tool for loading the "http-api" in order to test and monitor its performance.

An example of a "urls-file" can be found below. It contains "http" (get) requests to an "http api" of an "sms" gateway - one "http" (get) request per line - processing data concerning the transmission of a message, such as the destination (da) and originating (oa) 
addresses of (mt) "sms", their message body (txt), a flag (reg) enabling or not the request for "delivery report" (dlr) as well as "fallback url" handing any "incoming" events, e.g. "smsc-ack" or "dlr" messages and a "message-id" (mintid) :
```sh
http://localhost:8080/httpapi?da=+0000000001&oa=1234&mintid=msgid_0001&reg=true&eventUrl=http://localhost:8080&txt=stress_test_message_0001
http://localhost:8080/httpapi?da=+0000000002&oa=1234&mintid=msgid_0002&reg=true&eventUrl=http://localhost:8080&txt=stress_test_message_0002
http://localhost:8080/httpapi?da=+0000000003&oa=1234&mintid=msgid_0003&reg=true&eventUrl=http://localhost:8080&txt=stress_test_message_0003
```
Script's (core) source code can be found at https://blogs.oracle.com/unixcoach/entry/using_wget_to_test_the .
Updated with (line by line) comments and several changes by Aristotelis Metsinis.
