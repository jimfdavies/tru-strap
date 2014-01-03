#!/bin/bash

# Usage: init.sh --role webserver --environment prod1 --site a --repouser jimfdavies --reponame provtest-config

VERSION=0.0.1

# Install Puppet
# RHEL
yum install -y http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
yum install -y puppet

# TODO: Debian Puppet install

# Process command line params

function print_version {
  echo $1 $2
}

function print_help {
  echo Heeelp.
}

function set_facter {
  export FACTER_$1=$2
  puppet apply -e "file { '/etc/facter': ensure => directory, mode => 0600 }" --logdest syslog
  puppet apply -e "file { '/etc/facter/facts.d': ensure => directory, mode => 0600 }" --logdest syslog
  puppet apply -e "file { '/etc/facter/facts.d/$1.txt': ensure => present, mode => 0600, content => '$1=$2' }" --logdest syslog
  echo "Facter says $1 is..."
  facter $1
}

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
  --repouser|-o)
    set_facter init_repouser $2
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

# Set Git login params
# GITHUB_PRI_KEY=<Rightscale Credential??>
# GITHUB_PUB_KEY=<Rightscale Credential??>
# puppet apply -v -e "file {'id_rsa.pub': path => '/root/.ssh/id_rsa.pub', ensure => present, mode => 0600, content => '$GITHUB_PUB_KEY'}"
# puppet apply -v -e "file {'id_rsa': path => '/root/.ssh/id_rsa',ensure => present, mode    => 0600, content => '$GITHUB_PRI_KEY'}"
puppet apply -e "package { 'git': ensure => present }" 
puppet apply -e "file { '/opt/config': ensure => absent, force => true }"

# PUBLIC config repository only
#git clone -v https://github.com/jimfdavies/provtest-config.git /opt/config
git clone -v https://github.com/$FACTER_init_repouser/$FACTER_init_reponame.git /opt/config
# PRIVATE config repository
#git clone git@github.com:$REPOORG/$REPONAME.git /opt/config

puppet apply -e "file { '/etc/config': ensure => directory, mode => 0600 }"
puppet apply -e "file { '/etc/puppet/puppet.conf': ensure => present, mode => 0600, source => '/opt/config/puppet/puppet.conf' }"
puppet apply -e "file { '/etc/puppet/hiera.yaml': ensure => present, mode => 0600, source => '/opt/config/puppet/hiera.yaml' }"
puppet apply -e "file { '/etc/hiera.yaml': ensure => link, target => '/etc/puppet/hiera.yaml' }"
puppet apply -e "file { '/etc/puppet/Puppetfile': ensure => present, mode => 0600, source => '/opt/config/puppet/Puppetfile' }"

gem install librarian-puppet --no-ri --no-rdoc
cd /opt/config/puppet
librarian-puppet install
librarian-puppet update
librarian-puppet show

puppet apply --modulepath /opt/config/puppet/modules /opt/config/puppet/manifests/site.pp

# # Post setup
# <Set crontab>
# <puppet schedule config>
# puppet apply -v -e "class {'puppet-schedule'}"  (New Class containing new cron getting info from Hiera including disable)
# <Get latest copy of this boot script>
