# site.pp

node default {

  notify {"I am Puppet.":}

  Exec { 
    path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
  }

  notify {"Role: $::init_role": }

  hiera_include('classes')

  #include puppetfirstrun
}