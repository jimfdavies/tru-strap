class puppetfirstrun::service { 
  service { "puppet": 
    ensure => running, 
    hasstatus => true, 
    hasrestart => true, 
    enable => true, 
    require => Class["puppetfirstrun::config"], 
  } 
} 