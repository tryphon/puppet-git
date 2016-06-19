class git::common {

  package { git-core: 
    alias => git,
    ensure => latest
  }

  if $debian::lenny {
    include apt::backports
    apt::preferences { "git":
      package => "git", 
      pin => "release a=lenny-backports",
      priority => 999,
      before => Package[git-core]
    }
  }
}
