class bootstrap::profile::cache_rpms {
  $pkglist = template('bootstrap/packages.erb')
  $repo_base = '/var/yum'
  $repo_dir = "${repo_base}/mirror"
  file { [$repo_base,$repo_dir]:
    ensure => directory,
    before => Exec['cache packages'],
  }
  package { 'createrepo':
    ensure => present,
  }
  exec {'cache packages':
    command   => "repotrack -p ${repo_dir} ${pkglist}",
    path      => '/bin',
    timeout   => '600',
    logoutput => false,
    require   => Yumrepo['epel'],
  }
  exec {"createrepo .":
    path      => '/bin',
    cwd       => $repo_dir,
    logoutput => true,
    require   => [Exec['cache packages'],Package['createrepo']],
    before    => Yumrepo['local'],
  }
  yumrepo { 'local':
    name     => 'local',
    baseurl  => "file://${repo_dir}",
    enabled  => 1,
    gpgcheck => 0,
    priority => 1,
  }
}