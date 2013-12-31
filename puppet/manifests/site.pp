# site.pp

node default {

  notify {"I am Puppet.":}
  notify {"Role: $::init_role": }

  hiera_include('classes')

}