class puppetfirstrun::install { 
	if $::operatingsystem == Redhat {
  		package { "puppet" : 
    	ensure => present, 
  		} 
  	}
} 
