Sheepsafe
=========

http://github.com/nicksieger/sheepsafe

## Description

Sheepsafe is a small utility to keep you safe from [FireSheep][]!
It's a tool for mobile geeks.

We all know the cookie-stealing issue has been out there for a while,
but now with [FireSheep][], it just got way too easy. If you're like
me, I don't want to get exposed at the next gathering of techies at a
conference or even at a local coffee shop with this thing out there.
So I built Sheepsafe for myself.

Sheepsafe was built to automate the task of switching your network
configuration to use a SOCKS proxy whenever you join an untrusted
network.

Sheepsafe works by keeping a configuration of known safe wireless
networks. When you join an untrusted network, Sheepsafe switches to a
network location that has a SOCKS proxy configured and starts a SOCKS
proxy by SSH'ing into a remote server, thus protecting your browsing
traffic from FireSheep and other snoopers on the local network. When
you switch back to a safe network, Sheepsafe switches back to the
default, trusted location and shuts down the SOCKS proxy.

You could probably use something like [Marco Polo][polo] for this too,
but this setup Works For Me. 

## Requirements

- Mac OS X. That's what I run. You'll have to cook something else up
  for a different OS. Tested on 10.6.
- An SSH account on a remote server that can serve as a SOCKS proxy
  through which to tunnel traffic. Typically this can be an EC2
  server, a VPS, or some other cloud instance.
- Ruby 1.8.7 or greater. The Mac OS X system-installed Ruby is
  preferred as the OS will be launching Sheepsafe in the background.

## Install

- First install the gem: `sudo gem install sheepsafe`. It's
  recommended to install using the system Ruby to minimize
  difficulties informing launchd about an [RVM][] or some other
  package manager.
- After installing the gem, run `sheepsafe install` and follow the
  prompts for configuring Sheepsafe.

### Setting up the "Untrusted" location

One manual step that you need to do during installation is to create
an "Untrusted" location for Sheepsafe to configure and use when you're
on an untrusted network. Sheepsafe will prompt you to do these steps
during installation.

![Edit locations...](http://github.com/nicksieger/sheepsafe/raw/master/doc/edit-locations.jpg)

![Add Untrusted and Apply...](http://github.com/nicksieger/sheepsafe/raw/master/doc/add-untrusted-apply.jpg)

## Growl

If you wish to receive Growl notifications when Sheepsafe is switching
your location, be sure to install the `growlnotify` utility from the
"Extras" folder in the Growl .dmg.

## Post-install

Be sure you configure your applications to use system-wide proxy
settings for making connections, where applicable.

## Uninstall

- Run `sheepsafe uninstall` to unregister the Launchd task and remove
  Sheepsafe vestiges from your system.

[FireSheep]: http://codebutler.com/firesheep
[RVM]: http://rvm.beginrescueend.com/
[polo]: http://www.symonds.id.au/marcopolo/
