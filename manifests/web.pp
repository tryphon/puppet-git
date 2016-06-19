class git::web {
  include apache2

  package { gitweb: }

  file { "/etc/git": 
    ensure => directory
  }

  file { "/etc/git/gitweb.conf": 
    source => "puppet:///modules/git/gitweb.conf"
  }
  file { "/etc/gitweb.conf":
    ensure => "/etc/git/gitweb.conf",
  }

  apache2::confd_file { git:
    source => "puppet:///modules/git/apache2.conf"
  }
}
