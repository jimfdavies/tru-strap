#!/bin/bash

# Master boot script
# Design goals:
# Linux (rhel/debian) and Windows versions
# Run at command line
# Easy to put into USERDATA

# Usage: init.sh --role web-api --environment production [--site a] --repo-org TravelSupermarket --repo-name provisioning --update true

VERSION=0.0.1

# Install Puppet
# RHEL
yum install -y http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
yum install -y puppet

# Debian
# Cat /etc/issue cut to get version
# wget http://apt.puppetlabs.com/puppetlabs-release-<version>.deb
# sudo dpkg -i puppetlabs-release-<version>.deb
# sudo apt-get update

function print_version {
  echo $1 $2
}

function print_help {
  echo Heeelp.
}

function set_facter {
  export FACTER_$1=$2
  puppet apply -e "file { '/etc/facter/facts.d/$1.txt': ensure => present, mode => 0600, content => '$1=$2' }"
  echo "Facter says $1 is..."
  facter $1
}

# # Process command line params
while test -n "$1"; do
  case "$1" in
  --help|-h)
    print_help
    exit 
    ;;
  --version|-v) 
    print_version $PROGNAME $VERSION
    exit
    ;;
  --role|-r)
    set_facter init_role $2
    shift
    ;;
  --environment|-e)
    set_facter init_env $2
    shift
    ;;
  --site|-s)
    set_facter init_site $2
    shift
    ;;
  --repoorg|-o)
    set_facter init_repoorg $2
    shift
    ;;
  --reponame|-n)
    set_facter init_reponame $2
    shift
    ;;
  *)
    echo "Unknown argument: $1"
    print_help
    exit
    ;;
  esac
  shift
done

# # Set Local variables
# GITHUB_PRI_KEY=<Rightscale Credential??>
# GITHUB_PUB_KEY=<Rightscale Credential??>
# Set Git login params
# ?? puppet apply -v -e "file {'id_rsa.pub': path => '/root/.ssh/id_rsa.pub', ensure => present, mode => 0600, content => '$GITHUB_PUB_KEY'}"
# ?? puppet apply -v -e "file {'id_rsa': path => '/root/.ssh/id_rsa',ensure => present, mode    => 0600, content => '$GITHUB_PRI_KEY'}"
puppet apply -e "package { 'git': ensure => present }"

puppet apply -e "file { '/opt/config': ensure => absent, force => true }"

# PUBLIC config repository only
git clone -v https://github.com/jimfdavies/provtest-config.git /opt/config
# PRIVATE config repository
#git clone git@github.com:$REPOORG/$REPONAME.git /opt/config

puppet apply -e "file { 'config': path => '/etc/config', ensure => directory, mode => 0600 }"
puppet apply -e "file { 'puppet.conf': path => '/etc/puppet/puppet.conf', ensure => present, mode => 0600, source => '/opt/config/puppet/puppet.conf' }"
puppet apply -e "file { '/etc/puppet/hiera.yaml': ensure => present, mode => 0600, source => '/opt/config/puppet/hiera.yaml' }"
puppet apply -e "file { '/etc/hiera.yaml': ensure => link, target => '/etc/puppet/hiera.yaml' }"
puppet apply -e "file { '/etc/facter/facts.d/init_role.txt': ensure => present, mode => 0600, content => 'init_role=webserver' }"

# How do we download only the required external puppet modules?
# puppet-librarian requires all modules to be separate though
# 1. Run Puppet module that creates a Puppetfile based on Hiera parameter (required_modules)
# 2. Run puppet-librarian

# <puppet module git repo paths>
# <Git clone Puppet modules>
# <Apply Puppet modules>
# Run /opt/config/puppet/modulelist.sh
# # Iterate over list
# # git clone
# # puppet install module
# # ...

puppet apply --modulepath /opt/config/puppet/modules /opt/config/puppet/manifests/site.pp

# # Post setup
# <Set crontab>
# <puppet schedule config>
# puppet apply -v -e "class {'puppet-schedule'}"  (New Class containing new cron getting info from Hiera including disable)
# <Update this boot script>
