# site.pp

node default {

  notify {"I am Puppet.":}

  Exec { 
    path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
  }

  include puppetfirstrun
}