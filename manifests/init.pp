# == Class: golang
#
# Installs the go language allowing you to
# execute and compile go.
#
# === Examples
#
#  class { "golang":}
#
# === Authors
#
# Darren Coxall <darren@darrencoxall.com>
#
class golang (
  $version          = "1.4.2",
  $workspace        = "/vagrant",
  $arch             = "linux-amd64",
  $download_dir     = "/usr/local/src",
  $download_url     = undef,
  $profile_template = "golang/golang.sh.erb",
) {

  if ($download_url) {
    $download_location = $download_url
  } else {
    $download_location = "https://storage.googleapis.com/golang/go${version}.${arch}.tar.gz"
  }

  Exec {
    path => "/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin",
  }

  if ! defined(Package['curl']) {
    package { "curl": }
  }

  if ! defined(Package['mercurial']) {
    package { "mercurial": }
  }

  exec { "download":
    command => "curl -o $download_dir/go-$version.tar.gz $download_location",
    creates => "$download_dir/go-$version.tar.gz",
    unless  => "which go && go version | grep '$version'",
    require => Package["curl"],
  } ->
  exec { "unarchive":
    command => "tar -C /usr/local -xzf $download_dir/go-$version.tar.gz && rm $download_dir/go-$version.tar.gz",
    onlyif  => "test -f $download_dir/go-$version.tar.gz",
  }

  exec { "remove-previous":
    command => "rm -r /usr/local/go",
    onlyif  => [
      "test -d /usr/local/go",
      "which go && test `go version | cut -d' ' -f 3` != 'go$version'",
    ],
    before  => Exec["unarchive"],
  }

  # setup workspace
  $go_workspace_dirs = [ "$workspace", "$workspace/bin", "$workspace/pkg", "$workspace/src" ]

  file { $go_workspace_dirs:
    ensure => directory,
  }

  file { "/etc/profile.d/golang.sh":
    content => template("$profile_template"),
    owner   => root,
    group   => root,
    mode    => "a+x",
  }

}
