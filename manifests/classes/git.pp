class git {
  include git::common
  include git::storage

  # Create a new git repository
  define repository {
    include git::storage
    include git::common

    file { "/srv/git/$name": 
      ensure => directory,
      mode => 775,
      group => src,
      require => File["/srv/git"]
    }
    file { "/srv/git/$name/description":
      content => "$name"
    }
    exec { "git-init-$name":
      command => "git --bare init --shared && git update-server-info && chgrp -R src /srv/git/$name && chmod -R g+w /srv/git/$name",
      cwd => "/srv/git/$name",
      creates => "/srv/git/$name/HEAD",
      require => Package[git]
    }
    file { "/srv/git/$name/hooks/post-update": 
      mode => 755,
      require => Exec["git-init-$name"]
    }

    # Used to manage several post-receive scripts
    file { "/srv/git/$name/hooks/post-receive": 
      source => "puppet:///git/run-post-receive.d",
      mode => 755,
      require => Exec["git-init-$name"]
    }
    file { "/srv/git/$name/hooks/post-receive.d": 
      ensure => directory,
      require => Exec["git-init-$name"]
    }
  }

}

class git::storage {
  # Directory to store git repositories
  file { "/srv/git": 
    ensure => directory,
    mode => 2755,
    group => src
  }

  file { "/usr/local/sbin/git-cron":
    source => "puppet:///git/git-cron",
    mode => 755
  }
  file { "/etc/cron.daily/git-cron":
    ensure => "/usr/local/sbin/git-cron",
    require => File["/usr/local/sbin/git-cron"]
  }
}

class git::daemon {
  file { "/etc/init.d/git-daemon":
    source => "puppet:///git/git-daemon.initd",
    mode => 755
  }

  file { "/etc/default/git-daemon":
    source => "puppet:///git/git-daemon.default",
    notify => Service["git-daemon"]
  }

  service { "git-daemon":
    ensure => running,
    enable => true,
    require => [File["/etc/default/git-daemon"], File["/etc/init.d/git-daemon"]]
  }
}
