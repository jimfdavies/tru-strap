"Tru-Strap" - Next-Gen Bootstrap Prototype 
==========================================

This repository contains a mechanism to effectively bootstrap a configuration to a new server instance.  
This is very much a work-in-progress and its functionality should not be taken to be production-ready.
It merely proves out a process.

Problem statement
-----------------
Feature: Bootstrap initial Puppet run  
  In order to deploy configuration, services and applications to a new server instance  
  As an Ops Engineer or Developer  
  I want to insert a script at boot time that acquires the relevant configuration for that server instance  
  And initializes a Puppet run  

Design goals:
* Must separate configuration data from code
* Should work on organisational supported operating systems (RHEL-based, Debian-based, Windows)
* Should work in organisational supported deployment scenarios (Rightscale, AWS native, Vagrant/Virtualbox, VMWare, ruby-fog)
* Should run from command line and using a shell interpreter (Bash, Windows CMD)
* Should follow organisational Architectural Principles

The above scenario can used for testing the mechanism on a Vagrant machine.
Install Vagrant http://www.vagrantup.com/

    $ git clone https://github.com/jimfdavies/provtest-config.git
    $ cd provtest-config/masterboot
    $ vagrant up
    $ gem install cucumber
    $ cucumber features\bootstrap.feature

Solution
--------
We used the following technologies to achieve the above:
* [Puppet Standalone](http://docs.puppetlabs.com/references/3.4.0/man/apply.html)
* [Facter custom facts](http://docs.puppetlabs.com/guides/custom_facts.html#external-facts)
* [Hiera](http://docs.puppetlabs.com/hiera/1/)
* [Puppet Modulefile](http://docs.puppetlabs.com/puppet/3/reference/modules_publishing.html)
* [Librarian-Puppet](https://github.com/rodjek/librarian-puppet)

The whole shebang hinges on your Puppet modules being stored standalone and "Forge-fit" in GitHub. 
However you could make this mechanism work using other bases. 

The secret sauce is Hiera being used as a [lightweight ENC](http://docs.puppetlabs.com/hiera/1/puppet.html#assigning-classes-to-nodes-with-hiera-hierainclude).
We end up with configuration files that resemble the traditional nodes.pp but with the added power of hierarchical lookup and structured data types.

Execution
---------
* We start off proceedings with a shell script (see masterboot/init.sh) and some arbitrary command-line switches.
* These switches are made into external Facter facts using environment variables and also by creating external fact files.
* We then download this repository you're in now. We only want the puppet directory though really.
* We put the Puppet and Hiera config files into place and the initial Puppetfile.
* We install librarian-puppet and download the required Puppet modules.
* Finally we run puppet apply.

* Puppet apply starts with site.pp. Site.pp uses the Hiera function hiera_include so we can define classes for each role/environment/etc in the Hiera data sources.
* The correct data sources (with classes and parameters) are found by Hiera using the Facter facts we defined at the command-line.
* Puppet now executes as normal.

TODO
----
* Chaining/ordering of class installation (Puppet run stages?)
* Secure configuration data storage (Hiera GPG?)
* Management of Puppetfile (new module + ERB?)
* Advanced management of module dependencies (Modulefile with non-Forge dependencies allowed?)