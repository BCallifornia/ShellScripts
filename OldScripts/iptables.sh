#!/bin/sh
#
###############################################################################
# 
# Local Settings
#

# sysctl location.  If set, it will use sysctl to adjust the kernel parameters.
# If this is set to the empty string (or is unset), the use of sysctl
# is disabled.

SYSCTL="/sbin/sysctl -w" 

# To echo the value directly to the /proc file instead
# SYSCTL=""

# IPTables Location - adjust if needed

IPT="/sbin/iptables"
IPTS="/sbin/iptables-save"
IPTR="/sbin/iptables-restore"

# Internet Interface
INET_IFACE="wan"
INET_ADDRESS="94.23.163.36"

# Local Interface Information
LOCAL_IFACE="lan"
LOCAL_IP="172.16.10.254"
LOCAL_NET="172.16.10.0/24"
LOCAL_BCAST="172.16.10.255"

# Localhost Interface

LO_IFACE="lo"
LO_IP="127.0.0.1"

# Save and Restore arguments handled here
if [ "$1" = "save" ]
then
	echo "Saving firewall to /etc/sysconfig/iptables ... "
	$IPTS > /etc/sysconfig/iptables
	echo "done"
	exit 0
elif [ "$1" = "restore" ]
then
	echo "Restoring firewall from /etc/sysconfig/iptables ... "
	$IPTR < /etc/sysconfig/iptables
	echo "done"
	exit 0
fi

###############################################################################
#
# Load Modules
#

echo "Loading kernel modules ..."

# You should uncomment the line below and run it the first time just to
# ensure all kernel module dependencies are OK.  There is no need to run
# every time, however.

# /sbin/depmod -a

# Unless you have kernel module auto-loading disabled, you should not
# need to manually load each of these modules.  Other than ip_tables,
# ip_conntrack, and some of the optional modules, I've left these
# commented by default.  Uncomment if you have any problems or if
# you have disabled module autoload.  Note that some modules must
# be loaded by another kernel module.

# core netfilter module
/sbin/modprobe ip_tables

# the stateful connection tracking module
/sbin/modprobe ip_conntrack

# filter table module
# /sbin/modprobe iptable_filter

# mangle table module
# /sbin/modprobe iptable_mangle

# nat table module
# /sbin/modprobe iptable_nat

# LOG target module
# /sbin/modprobe ipt_LOG

# This is used to limit the number of packets per sec/min/hr
# /sbin/modprobe ipt_limit

# masquerade target module
# /sbin/modprobe ipt_MASQUERADE

# filter using owner as part of the match
# /sbin/modprobe ipt_owner

# REJECT target drops the packet and returns an ICMP response.
# The response is configurable.  By default, connection refused.
# /sbin/modprobe ipt_REJECT

# This target allows packets to be marked in the mangle table
# /sbin/modprobe ipt_mark

# This target affects the TCP MSS
# /sbin/modprobe ipt_tcpmss

# This match allows multiple ports instead of a single port or range
# /sbin/modprobe multiport

# This match checks against the TCP flags
# /sbin/modprobe ipt_state

# This match catches packets with invalid flags
# /sbin/modprobe ipt_unclean

# The ftp nat module is required for non-PASV ftp support
/sbin/modprobe ip_nat_ftp

# the module for full ftp connection tracking
/sbin/modprobe ip_conntrack_ftp

# the module for full irc connection tracking
/sbin/modprobe ip_conntrack_irc


###############################################################################
#
# Kernel Parameter Configuration
#
# See http://ipsysctl-tutorial.frozentux.net/chunkyhtml/index.html
# for a detailed tutorial on sysctl and the various settings
# available.

# Required to enable IPv4 forwarding.
# Redhat users can try setting FORWARD_IPV4 in /etc/sysconfig/network to true
# Alternatively, it can be set in /etc/sysctl.conf
if [ "$SYSCTL" = "" ]
then
    echo "1" > /proc/sys/net/ipv4/ip_forward
else
    $SYSCTL net.ipv4.ip_forward="1"
fi

# This enables dynamic address hacking.
# This may help if you have a dynamic IP address \(e.g. slip, ppp, dhcp\).
#if [ "$SYSCTL" = "" ]
#then
#    echo "1" > /proc/sys/net/ipv4/ip_dynaddr
#else
#    $SYSCTL net.ipv4.ip_dynaddr="1"
#fi

# This enables SYN flood protection.
# The SYN cookies activation allows your system to accept an unlimited
# number of TCP connections while still trying to give reasonable
# service during a denial of service attack.
if [ "$SYSCTL" = "" ]
then
    echo "1" > /proc/sys/net/ipv4/tcp_syncookies
else
    $SYSCTL net.ipv4.tcp_syncookies="1"
fi

# This enables source validation by reversed path according to RFC1812.
# In other words, did the response packet originate from the same interface
# through which the source packet was sent?  It's recommended for single-homed
# systems and routers on stub networks.  Since those are the configurations
# this firewall is designed to support, I turn it on by default.
# Turn it off if you use multiple NICs connected to the same network.
if [ "$SYSCTL" = "" ]
then
    echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter
else
    $SYSCTL net.ipv4.conf.all.rp_filter="1"
fi

# This option allows a subnet to be firewalled with a single IP address.
# It's used to build a DMZ.  Since that's not a focus of this firewall
# script, it's not enabled by default, but is included for reference.
# See: http://www.sjdjweis.com/linux/proxyarp/ 
#if [ "$SYSCTL" = "" ]
#then
#    echo "1" > /proc/sys/net/ipv4/conf/all/proxy_arp
#else
#    $SYSCTL net.ipv4.conf.all.proxy_arp="1"
#fi

# The following kernel settings were suggested by Alex Weeks. Thanks!

# This kernel parameter instructs the kernel to ignore all ICMP
# echo requests sent to the broadcast address.  This prevents
# a number of smurfs and similar DoS nasty attacks.
if [ "$SYSCTL" = "" ]
then
    echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
else
    $SYSCTL net.ipv4.icmp_echo_ignore_broadcasts="1"
fi

# This option can be used to accept or refuse source routed
# packets.  It is usually on by default, but is generally
# considered a security risk.  This option turns it off.
if [ "$SYSCTL" = "" ]
then
    echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route
else
    $SYSCTL net.ipv4.conf.all.accept_source_route="0"
fi

# This option can disable ICMP redirects.  ICMP redirects
# are generally considered a security risk and shouldn't be
# needed by most systems using this generator.
#if [ "$SYSCTL" = "" ]
#then
#    echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects
#else
#    $SYSCTL net.ipv4.conf.all.accept_redirects="0"
#fi

# However, we'll ensure the secure_redirects option is on instead.
# This option accepts only from gateways in the default gateways list.
if [ "$SYSCTL" = "" ]
then
    echo "1" > /proc/sys/net/ipv4/conf/all/secure_redirects
else
    $SYSCTL net.ipv4.conf.all.secure_redirects="1"
fi

# This option logs packets from impossible addresses.
if [ "$SYSCTL" = "" ]
then
    echo "1" > /proc/sys/net/ipv4/conf/all/log_martians
else
    $SYSCTL net.ipv4.conf.all.log_martians="1"
fi


###############################################################################
#
# Flush Any Existing Rules or Chains
#

echo "Flushing Tables ..."

# Reset Default Policies
$IPT -P INPUT ACCEPT
$IPT -P FORWARD ACCEPT
$IPT -P OUTPUT ACCEPT
$IPT -t nat -P PREROUTING ACCEPT
$IPT -t nat -P POSTROUTING ACCEPT
$IPT -t nat -P OUTPUT ACCEPT
$IPT -t mangle -P PREROUTING ACCEPT
$IPT -t mangle -P OUTPUT ACCEPT

# Flush all rules
$IPT -F
$IPT -t nat -F
$IPT -t mangle -F

# Erase all non-default chains
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

if [ "$1" = "stop" ]
then
	echo "Firewall completely flushed!  Now running with no firewall."
	exit 0
fi

###############################################################################
#
# Rules Configuration
#

###############################################################################
#
# Filter Table
#
###############################################################################

# Set Policies

$IPT -P INPUT DROP
$IPT -P OUTPUT DROP
$IPT -P FORWARD DROP

###############################################################################
#
# User-Specified Chains
#
# Create user chains to reduce the number of rules each packet
# must traverse.

echo "Create and populate custom rule chains ..."

# Create a chain to filter INVALID packets

$IPT -N bad_packets

# Create another chain to filter bad tcp packets

$IPT -N bad_tcp_packets

# Create separate chains for icmp, tcp (incoming and outgoing),
# and incoming udp packets.

$IPT -N icmp_packets

# Used for UDP packets inbound from the Internet
$IPT -N udp_inbound

# Used to block outbound UDP services from internal network
# Default to allow all
$IPT -N udp_outbound

# Used to allow inbound services if desired
# Default fail except for established sessions
$IPT -N tcp_inbound

# Used to block outbound services from internal network
# Default to allow all
$IPT -N tcp_outbound

###############################################################################
#
# Populate User Chains
#

# bad_packets chain
#

# Drop packets received on the external interface
# claiming a source of the local network
$IPT -A bad_packets -p ALL -i $INET_IFACE -s $LOCAL_NET -j LOG \
    --log-prefix "Illegal source: "

$IPT -A bad_packets -p ALL -i $INET_IFACE -s $LOCAL_NET -j DROP

# Drop INVALID packets immediately
$IPT -A bad_packets -p ALL -m state --state INVALID -j LOG \
    --log-prefix "Invalid packet: "

$IPT -A bad_packets -p ALL -m state --state INVALID -j DROP

# Then check the tcp packets for additional problems
$IPT -A bad_packets -p tcp -j bad_tcp_packets

# All good, so return
$IPT -A bad_packets -p ALL -j RETURN

# bad_tcp_packets chain
#
# All tcp packets will traverse this chain.
# Every new connection attempt should begin with
# a syn packet.  If it doesn't, it is likely a
# port scan.  This drops packets in state
# NEW that are not flagged as syn packets.

# Return to the calling chain if the bad packets originate
# from the local interface. This maintains the approach
# throughout this firewall of a largely trusted internal
# network.
$IPT -A bad_tcp_packets -p tcp -i $LOCAL_IFACE -j RETURN

# However, I originally did apply this filter to the forward chain
# for packets originating from the internal network.  While I have
# not conclusively determined its effect, it appears to have the
# interesting side effect of blocking some of the ad systems.
# Apparently some ad systems have the browser initiate a NEW
# connection that is not flagged as a syn packet to retrieve
# the ad image.  If you wish to experiment further comment the
# rule above. If you try it, you may also wish to uncomment the
# rule below.  It will keep those packets from being logged.
# There are a lot of them.
# $IPT -A bad_tcp_packets -p tcp -i $LOCAL_IFACE ! --syn -m state \
#     --state NEW -j DROP

$IPT -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j LOG \
    --log-prefix "New not syn: "
$IPT -A bad_tcp_packets -p tcp ! --syn -m state --state NEW -j DROP

$IPT -A bad_tcp_packets -p tcp --tcp-flags ALL NONE -j LOG \
    --log-prefix "Stealth scan: "
$IPT -A bad_tcp_packets -p tcp --tcp-flags ALL NONE -j DROP

$IPT -A bad_tcp_packets -p tcp --tcp-flags ALL ALL -j LOG \
    --log-prefix "Stealth scan: "
$IPT -A bad_tcp_packets -p tcp --tcp-flags ALL ALL -j DROP

$IPT -A bad_tcp_packets -p tcp --tcp-flags ALL FIN,URG,PSH -j LOG \
    --log-prefix "Stealth scan: "
$IPT -A bad_tcp_packets -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP

$IPT -A bad_tcp_packets -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j LOG \
    --log-prefix "Stealth scan: "
$IPT -A bad_tcp_packets -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP

$IPT -A bad_tcp_packets -p tcp --tcp-flags SYN,RST SYN,RST -j LOG \
    --log-prefix "Stealth scan: "
$IPT -A bad_tcp_packets -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

$IPT -A bad_tcp_packets -p tcp --tcp-flags SYN,FIN SYN,FIN -j LOG \
    --log-prefix "Stealth scan: "
$IPT -A bad_tcp_packets -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

# All good, so return
$IPT -A bad_tcp_packets -p tcp -j RETURN

# icmp_packets chain
#
# This chain is for inbound (from the Internet) icmp packets only.
# Type 8 (Echo Request) is not accepted by default
# Enable it if you want remote hosts to be able to reach you.
# 11 (Time Exceeded) is the only one accepted
# that would not already be covered by the established
# connection rule.  Applied to INPUT on the external interface.
# 
# See: http://www.ee.siue.edu/~rwalden/networking/icmp.html
# for more info on ICMP types.
#
# Note that the stateful settings allow replies to ICMP packets.
# These rules allow new packets of the specified types.

# ICMP packets should fit in a Layer 2 frame, thus they should
# never be fragmented.  Fragmented ICMP packets are a typical sign
# of a denial of service attack.
$IPT -A icmp_packets --fragment -p ICMP -j LOG \
    --log-prefix "ICMP Fragment: "
$IPT -A icmp_packets --fragment -p ICMP -j DROP

# Echo - uncomment to allow your system to be pinged.
# Uncomment the LOG command if you also want to log PING attempts
# 
# $IPT -A icmp_packets -p ICMP -s 0/0 --icmp-type 8 -j LOG \
#    --log-prefix "Ping detected: "
$IPT -A icmp_packets -p ICMP -s 0/0 --icmp-type 8 -j ACCEPT

# By default, however, drop pings without logging. Blaster
# and other worms have infected systems blasting pings.
# Comment the line below if you want pings logged, but it
# will likely fill your logs.
$IPT -A icmp_packets -p ICMP -s 0/0 --icmp-type 8 -j DROP

# Time Exceeded
$IPT -A icmp_packets -p ICMP -s 0/0 --icmp-type 11 -j ACCEPT

# Not matched, so return so it will be logged
$IPT -A icmp_packets -p ICMP -j RETURN

# TCP & UDP
# Identify ports at:
#    http://www.chebucto.ns.ca/~rakerman/port-table.html
#    http://www.iana.org/assignments/port-numbers

# udp_inbound chain
#
# This chain describes the inbound UDP packets it will accept.
# It's applied to INPUT on the external or Internet interface.
# Note that the stateful settings allow replies.
# These rules are for new requests.
# It drops netbios packets (windows) immediately without logging.

# Drop netbios calls
# Please note that these rules do not really change the way the firewall
# treats netbios connections.  Connections from the localhost and
# internal interface (if one exists) are accepted by default.
# Responses from the Internet to requests initiated by or through
# the firewall are also accepted by default.  To get here, the
# packets would have to be part of a new request received by the
# Internet interface.  You would have to manually add rules to
# accept these.  I added these rules because some network connections,
# such as those via cable modems, tend to be filled with noise from
# unprotected Windows machines.  These rules drop those packets
# quickly and without logging them.  This prevents them from traversing
# the whole chain and keeps the log from getting cluttered with
# chatter from Windows systems.
$IPT -A udp_inbound -p UDP -s 0/0 --destination-port 137 -j DROP
$IPT -A udp_inbound -p UDP -s 0/0 --destination-port 138 -j DROP

# Ident requests (Port 113) must have a REJECT rule rather than the
# default DROP rule.  This is the minimum requirement to avoid
# long delays while connecting.  Also see the tcp_inbound rule.
$IPT -A udp_inbound -p UDP -s 0/0 --destination-port 113 -j REJECT

# A more sophisticated configuration could accept the ident requests.
# $IPT -A udp_inbound -p UDP -s 0/0 --destination-port 113 -j ACCEPT

# However, if this is a gateway system that masquerades/nats for internal systems
# and the internal systems wish to chat, a simple changing these rules to
# ACCEPT won't work.  The ident daemon on the gateway will need to know how
# to handle the requests.  The stock daemon in most linux distributions
# can't do that.   oidentd is one package that can.
# See: http://dev.ojnk.net/

# Network Time Protocol (NTP) Server
$IPT -A udp_inbound -p UDP -s 0/0 --destination-port 123 -j ACCEPT


# Not matched, so return for logging
$IPT -A udp_inbound -p UDP -j RETURN

# udp_outbound chain
#
# This chain is used with a private network to prevent forwarding for
# UDP requests on specific protocols.  Applied to the FORWARD rule from
# the internal network.  Ends with an ACCEPT


# No match, so ACCEPT
$IPT -A udp_outbound -p UDP -s 0/0 -j ACCEPT

# tcp_inbound chain
#
# This chain is used to allow inbound connections to the
# system/gateway.  Use with care.  It defaults to none.
# It's applied on INPUT from the external or Internet interface.

# Ident requests (Port 113) must have a REJECT rule rather than the
# default DROP rule.  This is the minimum requirement to avoid
# long delays while connecting.  Also see the tcp_inbound rule.
$IPT -A tcp_inbound -p TCP -s 0/0 --destination-port 113 -j REJECT

# A more sophisticated configuration could accept the ident requests.
# $IPT -A tcp_inbound -p TCP -s 0/0 --destination-port 113 -j ACCEPT

# However, if this is a gateway system that masquerades/nats for internal systems
# and the internal systems wish to chat, a simple changing these rules to
# ACCEPT won't work.  The ident daemon on the gateway will need to know how
# to handle the requests.  The stock daemon in most linux distributions
# can't do that.   oidentd is one package that can.
# See: http://dev.ojnk.net/


# Email Server (SMTP)
#$IPT -A tcp_inbound -p TCP -s 0/0 --destination-port 25 -j ACCEPT

# Email Server (POP3)
#$IPT -A tcp_inbound -p TCP -s 0/0 --destination-port 110 -j ACCEPT

# Email Server (IMAP4)
#$IPT -A tcp_inbound -p TCP -s 0/0 --destination-port 143 -j ACCEPT

# sshd
$IPT -A tcp_inbound -p TCP -s 0/0 --destination-port 22 -j ACCEPT


# Not matched, so return so it will be logged
$IPT -A tcp_inbound -p TCP -j RETURN

# tcp_outbound chain
#
# This chain is used with a private network to prevent forwarding for
# requests on specific protocols.  Applied to the FORWARD rule from
# the internal network.  Ends with an ACCEPT


# No match, so ACCEPT
$IPT -A tcp_outbound -p TCP -s 0/0 -j ACCEPT

###############################################################################
#
# INPUT Chain
#

echo "Process INPUT chain ..."

# Allow all on localhost interface
$IPT -A INPUT -p ALL -i $LO_IFACE -j ACCEPT

# Drop bad packets
$IPT -A INPUT -p ALL -j bad_packets

# DOCSIS compliant cable modems
# Some DOCSIS compliant cable modems send IGMP multicasts to find
# connected PCs.  The multicast packets have the destination address
# 224.0.0.1.  You can accept them.  If you choose to do so,
# Uncomment the rule to ACCEPT them and comment the rule to DROP
# them  The firewall will drop them here by default to avoid
# cluttering the log.  The firewall will drop all multicasts
# to the entire subnet (224.0.0.1) by default.  To only affect
# IGMP multicasts, change '-p ALL' to '-p 2'.  Of course,
# if they aren't accepted elsewhere, it will only ensure that
# multicasts on other protocols are logged.
# Drop them without logging.
$IPT -A INPUT -p ALL -d 224.0.0.1 -j DROP
# The rule to accept the packets.
# $IPT -A INPUT -p ALL -d 224.0.0.1 -j ACCEPT

# Rules for the private network (accessing gateway system itself)
$IPT -A INPUT -p ALL -i $LOCAL_IFACE -s $LOCAL_NET -j ACCEPT
$IPT -A INPUT -p ALL -i $LOCAL_IFACE -d $LOCAL_BCAST -j ACCEPT

# Allow DHCP client request packets inbound from internal network
$IPT -A INPUT -p UDP -i $LOCAL_IFACE --source-port 68 --destination-port 67 \
     -j ACCEPT


# Inbound Internet Packet Rules

# Accept Established Connections
$IPT -A INPUT -p ALL -i $INET_IFACE -m state --state ESTABLISHED,RELATED \
     -j ACCEPT

# Route the rest to the appropriate user chain
$IPT -A INPUT -p TCP -i $INET_IFACE -j tcp_inbound
$IPT -A INPUT -p UDP -i $INET_IFACE -j udp_inbound
$IPT -A INPUT -p ICMP -i $INET_IFACE -j icmp_packets

# Drop without logging broadcasts that get this far.
# Cuts down on log clutter.
# Comment this line if testing new rules that impact
# broadcast protocols.
$IPT -A INPUT -m pkttype --pkt-type broadcast -j DROP

# Log packets that still don't match
$IPT -A INPUT -m limit --limit 3/minute --limit-burst 3 -j LOG \
    --log-prefix "INPUT packet died: "

###############################################################################
#
# FORWARD Chain
#

echo "Process FORWARD chain ..."

# Used if forwarding for a private network

# Drop bad packets
$IPT -A FORWARD -p ALL -j bad_packets

# Accept TCP packets we want to forward from internal sources
$IPT -A FORWARD -p tcp -i $LOCAL_IFACE -j tcp_outbound

# Accept UDP packets we want to forward from internal sources
$IPT -A FORWARD -p udp -i $LOCAL_IFACE -j udp_outbound

# If not blocked, accept any other packets from the internal interface
$IPT -A FORWARD -p ALL -i $LOCAL_IFACE -j ACCEPT

# Deal with responses from the internet
$IPT -A FORWARD -i $INET_IFACE -m state --state ESTABLISHED,RELATED \
     -j ACCEPT

# Port Forwarding is enabled, so accept forwarded traffic
$IPT -A FORWARD -p tcp -i $INET_IFACE --destination-port 3389 \
     --destination 172.16.10.30 -j ACCEPT 
$IPT -A FORWARD -p tcp -i $INET_IFACE --destination-port 20002:20003 \
     --destination 172.16.10.30 -j ACCEPT
$IPT -A FORWARD -p tcp -i $INET_IFACE --destination-port 80 \
     --destination 172.16.10.30 -j ACCEPT
$IPT -A FORWARD -p tcp -i $INET_IFACE --destination-port 20:21 \
     --destination 172.16.10.5 -j ACCEPT
$IPT -A FORWARD -p tcp -i $INET_IFACE --destination-port 62000:64000 \
     --destination 172.16.10.5 -j ACCEPT
$IPT -A FORWARD -p tcp -i $INET_IFACE --destination-port 9091 \
     --destination 172.16.10.5 -j ACCEPT
$IPT -A FORWARD -p tcp -i $INET_IFACE --destination-port 51413 \
     --destination 172.16.10.5 -j ACCEPT
$IPT -A FORWARD -p tcp -i $INET_IFACE --destination-port 80 \
     --destination 172.16.10.5 -j ACCEPT

# Log packets that still don't match
$IPT -A FORWARD -m limit --limit 3/minute --limit-burst 3 -j LOG \
    --log-prefix "FORWARD packet died: "

###############################################################################
#
# OUTPUT Chain
#

echo "Process OUTPUT chain ..."

# Generally trust the firewall on output

# However, invalid icmp packets need to be dropped
# to prevent a possible exploit.
$IPT -A OUTPUT -m state -p icmp --state INVALID -j DROP

# Localhost
$IPT -A OUTPUT -p ALL -s $LO_IP -j ACCEPT
$IPT -A OUTPUT -p ALL -o $LO_IFACE -j ACCEPT

# To internal network
$IPT -A OUTPUT -p ALL -s $LOCAL_IP -j ACCEPT
$IPT -A OUTPUT -p ALL -o $LOCAL_IFACE -j ACCEPT

# To internet
$IPT -A OUTPUT -p ALL -o $INET_IFACE -j ACCEPT

# Log packets that still don't match
$IPT -A OUTPUT -m limit --limit 3/minute --limit-burst 3 -j LOG \
    --log-prefix "OUTPUT packet died: "

###############################################################################
#
# nat table
#
###############################################################################

# The nat table is where network address translation occurs if there
# is a private network.  If the gateway is connected to the Internet
# with a static IP, snat is used.  If the gateway has a dynamic address,
# masquerade must be used instead.  There is more overhead associated
# with masquerade, so snat is better when it can be used.
# The nat table has a builtin chain, PREROUTING, for dnat and redirects.
# Another, POSTROUTING, handles snat and masquerade.

echo "Load rules for nat table ..."

###############################################################################
#
# PREROUTING chain
#

# Port Forwarding
# 
# Port forwarding forwards all traffic on a port or ports from
# the firewall to a computer on the internal LAN.  This can
# be required to support special situations.  For instance,
# this is the only way to support file transfers with an ICQ
# client on an internal computer.  It's also required if an internal
# system hosts a service such as a web server.  However, it's also
# a dangerous option.  It allows Internet computers access to
# your internal network.  Use it carefully and only if you're
# certain you know what you're doing.

$IPT -t nat -A PREROUTING -p tcp -i $INET_IFACE --destination-port 3389 \
     -j DNAT --to-destination 172.16.10.30
$IPT -t nat -A PREROUTING -p tcp -i $INET_IFACE --destination-port 20002:20003 \
     -j DNAT --to-destination 172.16.10.30
$IPT -t nat -A PREROUTING -p tcp -i $INET_IFACE --destination-port 88 \
     -j DNAT --to-destination 172.16.10.30:80
$IPT -t nat -A PREROUTING -p tcp -i $INET_IFACE --destination-port 20:21 \
     -j DNAT --to-destination 172.16.10.5
$IPT -t nat -A PREROUTING -p tcp -i $INET_IFACE --destination-port 62000:64000 \
     -j DNAT --to-destination 172.16.10.5
$IPT -t nat -A PREROUTING -p tcp -i $INET_IFACE --destination-port 9091 \
     -j DNAT --to-destination 172.16.10.5
$IPT -t nat -A PREROUTING -p tcp -i $INET_IFACE --destination-port 9080 \
     -j DNAT --to-destination 172.16.10.5:80
$IPT -t nat -A PREROUTING -p tcp -i $INET_IFACE --destination-port 51413 \
     -j DNAT --to-destination 172.16.10.5

###############################################################################
#
# POSTROUTING chain
#

$IPT -t nat -A POSTROUTING -o $INET_IFACE \
     -j SNAT --to-source $INET_ADDRESS

###############################################################################
#
# mangle table
#
###############################################################################

# The mangle table is used to alter packets.  It can alter or mangle them in
# several ways.  For the purposes of this generator, we only use its ability
# to alter the TTL in packets.  However, it can be used to set netfilter
# mark values on specific packets.  Those marks could then be used in another
# table like filter, to limit activities associated with a specific host, for
# instance.  The TOS target can be used to set the Type of Service field in
# the IP header.  Note that the TTL target might not be included in the
# distribution on your system.  If it is not and you require it, you will
# have to add it.  That may require that you build from source.

echo "Load rules for mangle table ..."

