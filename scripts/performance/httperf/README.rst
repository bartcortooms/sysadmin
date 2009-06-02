= Performance tests with httperf =

== Introduction ==

httperf is an HTTP load generator, and can be used to replay "sessions".  A
session is a recording of the actions (clicks) a typical visitor would take on
a certain website.  To create these session logs, we use a proxy which can
record the exact HTTP commands (usually only GETs and POSTs).  By letting
someone visit the website through this proxy, a session can be generated which
can later be replayed multiple times in parallel, to simulate multiple visitors
visiting the site at once.  The session contains timing information for the
commands as well, to make the generated load as realistic as possible.

A session can also be generated from the webserver logs, but it will not be as
detailed as a session recorded by a proxy.  For example, the data which was
POSTed by a form is not saved in the webserver log.

httperf can use multiple different session logs, to make the load test more
realistic and minimize any caching effects which could favourably influence the
results.  If it's expected that usage patterns will be different for every
visitor, it's best to use as many different sessions for the concurrent
visitors as possible.  For example, when simulating the load for 200 concurrent
visitors using 5 different sessions, 40 visitors will use the same session and
will all hit the same pages.  The cache will be more effective and thus the
results will appear to be better when compared to 200 concurrent visitors with
50 different sessions.

== Installation ==

We need two custom-built .deb packages to be able to record sessions and
replay them with httperf.  These packages can be downloaded from the Kumina
Debian repository at http://debian.kumina.nl/.  The following packages will
need to be retrieved from this repository instead of the default Debian
repository.

  ''httperf''::
    This is a package of a newer version of httperf than is
    currently available in the Debian repository.  It has also been patched
    to allow specifying the content type for HTTP requests.
  ''libhttp-recorder-httperf-perl''::
    This package contains a Perl subclass
    for HTTP::Recorder which allows recording user actions. This recording
    can be used as input for the httperf performance test tool.

To be able to install these packages with apt-get, add the following line to
your `/etc/apt/sources.list`:

{{{
deb     http://debian.kumina.nl/debian/   etch-kumina	main
}}}

Install the packages:

{{{
sudo apt-get update
sudo apt-get install libhttp-recorder-httperf-perl libhttp-proxy-perl httperf
}}}

Make sure this command installs the httperf package from the Kumina
repository. It should be version 0.9.0-0.kumina1:

{{{
$ dpkg -s httperf | grep ^Version
Version: 0.9.0-0.kumina1
}}}

If it's not the correct version, you may need to explicetely specify the
Kumina repository:

{{{
sudo apt-get -t kumina install httperf
}}}

== Recording a session ==

You can use the following Perl script to start a proxy which can record httperf
sessions:

{{{
#!/usr/bin/perl

use HTTP::Proxy;
use HTTP::Recorder::Httperf;

my $proxy = HTTP::Proxy->new();
my $agent = new HTTP::Recorder::Httperf;
$agent->temp_file('/tmp/httperf_recorder_time');

# set the log file (optional)
$agent->file("/tmp/httperf_proxy.log");

# set HTTP::Recorder as the agent for the proxy
$proxy->agent($agent);

# start the proxy
$proxy->host(undef);
$proxy->start();

1;
}}}

Save these lines in a file called `proxy.pl` and start it with:

{{{
$ chmod +x proxy.pl
$ ./proxy.pl
}}}

Change the proxy settings of your browser to use the hostname of the server
where you just started the proxy, and port 8080.  It's best to use Firefox for
this, and not Internet Explorer, as the proxy settings for Internet Explorer
are systemwide and will be used by other applications as well, and we only want
requests from Firefox to be included in the session recording.

Now visit the site you want to record a session of.  It's important to act as a
normal visitor - delays between clicks on links will be recorded as well and be
used when replaying the sesssion.

'''Note''': Do not visit any other sites while recording the session, otherwise
they'll be included in the session recording.  The proxy only records the paths for
the URLs, not the hostname, so httperf can't know which lines in the session to skip.


== Replaying a session ==

You can replay the recorded session with httperf:

{{{
$ cp /tmp/httperf_proxy.log session.log
$ httperf --hog --session-cookie --period=e0.2 --wsesslog=10,2.000,session.log --server=www.kumina.nl
}}}

This will test the performance of server www.kumina.nl with 10 simultaneous
sessions.

Explanation of the arguments used in the command above:

  ''--hog''::
    Use as many TCP ports as necessary.
  ''--session-cookie''::
    Needed when you need httperf to use the cookies which are
    returned by the webserver.  This is needed if your website uses
    cookies for authentication, for example.
  ''--period=e0.2''::
    Separate the sessions by the specified time interval.  See the
    httperf man page for details.
  ''--wsesslog=10,2.000,session.log''::
    Start 10 sessions, with a default thinking time of 2 seconds
    between requests, and use the sessions in the file session.log.
  ''--server=www.kumina.nl''::
    Replay the session for server www.kumina.nl.  If this is not
    the domain name of site, you need to specify --server-name as
    well.

See the [http://www.hpl.hp.com/research/linux/httperf/httperf-man-0.9.txt httperf man page] for more information on the arguments.

The proxy will not record any HTTP headers passed by the client when recording
a session, and the non-modified version of httperf doesn't support specifying headers
in the session log anyway.  Some headers may be need to be passed to be able
to properly replay the session, however.  One example of this are POSTs of HTML
forms: they often need the Content-Type header to be set to
"application/x-www-form-urlencoded" by the client.  If you're seeing lots of
401 (unauthorized), 301 or 302 (redirect) response codes, the httperf session
is probably not authenticating itself properly.  If your session contains a
POST of the login details to the login form, this could be because it's not
setting the correct Content-Type for the POST.

To allow specifying a Content-Type in the session log, we're using a patched
version of httperf which adds support for this.  You will need to change your
session log to make it set the correct Content-Type for POST requests.  Search
for every line which does a POST, such as:

{{{
/login.html method=POST contents="username=user&password=foo"
}}}

And change to line to make it set the content type:

{{{
/login.html method=POST ctype=application/x-www-form-urlencoded contents="username=user&password=foo"
}}}

Now restart httperf, and check you get proper 200 reponse codes. (The best
place to check for this is the webserver log.)
	
If you get the following error message when starting httperf, your httperf is
not the version from the Kumina repository:

{{{
httperf: did not recognize arg 'ctype=application/x-www-form-urlencoded' in <file>
}}}

== Interpreting the test results ==

When examing the test results, it's useful to know which data is important and
which isn't. A typical test result will look like this:

{{{
Maximum connect burst length: 2

Total: connections 543 requests 2750 replies 2324 test-duration 166.557 s

Connection rate: 3.3 conn/s (306.7 ms/conn, <=118 concurrent connections)
Connection time [ms]: min 17068.8 avg 32507.8 max 60511.6 median 30131.5 stddev 11500.9
Connection time [ms]: connect 0.3
Connection length [replies/conn]: 5.455

Request rate: 16.5 req/s (60.6 ms/req)
Request size [B]: 218.0

Reply rate [replies/s]: min 2.4 avg 14.1 max 43.8 stddev 12.1 (33 samples)
Reply time [ms]: response 72.1 transfer 1.9
Reply size [B]: header 260.0 content 33246.0 footer 0.0 (total 33506.0)
Reply status: 1xx=0 2xx=2174 3xx=150 4xx=0 5xx=0

CPU time [s]: user 54.52 system 112.04 (user 32.7% system 67.3% total 100.0%)
Net I/O: 460.1 KB/s (3.8*10^6 bps)

Errors: total 426 client-timo 0 socket-timo 0 connrefused 0 connreset 426
Errors: fd-unavail 0 addrunavail 0 ftab-full 0 other 0

Session rate [sess/s]: min 0.00 avg 0.00 max 0.00 stddev 0.00 (0/0)
Session: avg 0.00 connections/session
Session lifetime [s]: 0.0
Session failtime [s]: 0.0
Session length histogram: 0
There's actually only one line which is really important to us, and that's the line with the Reply time:

Reply time [ms]: response 72.1 transfer 1.9
}}}

This shows the average reply time for all requests made by httperf. The first
number, the response time (72.1 ms in this case), is the average number of
milliseconds which passed before the client started receiving a reply from the
server to its request. The second number, the transfer time (1.9 ms), is the
time it took for the entire reply to be transferred. For simple pages the
response time should typically be in the 100-300 ms range, or below.

The Error lines and Reply status line indicate when something is wrong. The
connreset number does not have to be 0, but a very high number indicates many
requests were aborted by the server. The Reply status line shows the different
status code categories for the HTTP replies. Status codes in the 2xx category
should be dominant here. 3xx codes are usually redirects (301 or 303). 4xx
errors usually come from a 401 (Unauthorized) and/or 404 (Not found) and can
indicate problems with the session log. Replies in the 5xx category are server
errors and indicate problems with the application itself.

'''Note''': Numbers only tell you a small part of the story. The best indication
of the performance of a site is real-user experience. To get a feeling for
how the site responds with a certain number of visitors, visit the site yourself
while doing the performance tests, and increase the number of visitors until the
site doesn't respond as quickly as you think it should anymore.
