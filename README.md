Sheepsafe
=========

http://github.com/nicksieger/sheepsafe

## Description:

Sheepsafe is a small utility to keep you safe from [FireSheep][]! 

Sheepsafe works by keeping a configuration of known safe wireless
networks. When you join an untrusted network, Sheepsafe switches to a
Network Location that has a SOCKS proxy set up and starts a SOCKS
proxy by SSH'ing into a remote server. When you switch back to a safe
network, Sheepsafe switches back to the default location and shuts
down the SOCKS proxy.

## Requirements

* Mac OS X. That's what I run. You'll have to cook something else up
  for a different OS. Tested on 10.6.
* An SSH account on a server SomeWhereElse(TM) that can serve as a
  SOCKS proxy through which to tunnel traffic. Typically this can be an
  EC2 server, a VPS, or some other cloud instance.
* Ruby 1.8.7 or greater. The Mac OS X system-installed Ruby is
  preferred as the OS will be launching Sheepsafe in the background.

## Install



[FireSheep]: http://codebutler.com/firesheep
