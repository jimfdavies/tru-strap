Feature: Bootstrap initial Puppet run
  In order to deploy configuration, services and applications to a new server instance
  As an Ops Engineer or Developer
  I want to insert a script at boot time that acquires the relevant configuration for that server instance
  And initializes a Puppet run

# Design goals:
# The process…
# Must separate configuration data from code
# Should work on organisational supported operating systems (RHEL-based, Debian-based, Windows)
# Should work in organisational supported deployment scenarios (Rightscale, AWS native, Vagrant/Virtualbox, VMWare, ruby-fog)
# Should run from command line and using a shell interpreter (Bash, Windows CMD)
# Should follow organisational Architectural Principles

# This cucumber script assumes you have installed and launched the Vagrant box configured by the Vagrantfile in this directory.
# Currently the step definitions simply run 'vagrant provision' and check the output for particular expected strings

  Scenario: Script is run via Vagrant Shell provisioner
    Given The vagrant machine is running
    When  I run vagrant provision
    Then  I should see in the output: puppet-3.4.1-1.el6.noarch already installed and latest version
    And   I should see in the output: I am from the webserver.yaml
    And   I want to view the output of this scenario

  Scenario: A test local SSH command is run on the Vagrant machine
    Given The vagrant machine is running
    When  I run vagrant ssh -c and this command: who
    Then  I should see in the output: vagrant

  Scenario: Check to see if files are in place
    Given The vagrant machine is running
    When  I run vagrant ssh -c and this command: "ls -la /opt/config/puppet"
    Then  I should see in the output: puppet.conf
    And   I want to view the output of this scenario