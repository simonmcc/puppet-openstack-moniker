# = Class: moniker::package
#
# Class to manage where we get moniker from (git/zip/deb etc)
#
# == Parameters:
#
# $moniker_version::   description of parameter. default value if any.
# $moniker_provider:: zip|git|package|pip
# $moniker_home::     
# $moniker_baseurl::  where to get the zip or git repo from
#
# == Actions:
#
# Makes sure that a moniker release is available
#
# == Requires:
#
# $moniker_provider='zip' is the simplest delivery message
# it pulls down master.zip from github
#
# == Sample Usage:
#
# == Todo:
#
# * Add better support for other ways providing the jar file?
#
class moniker::package(
  $moniker_home = '/opt/stack/moniker',
  $moniker_provider = 'git',
  $moniker_version = 'master',
  $moniker_baseurl = 'https://github.com/stackforge/moniker.git')
{

  if $moniker_provider == 'zip' {
    $moniker_url = "$moniker_baseurl/archive/$$moniker_version.zip"

    package { 'curl': }
    package { 'unzip': }

    file { $moniker_home: 
      ensure => directory,
    }

    # pull in moniker using the zip archive from github
    exec { 'curl-moniker-zip':
      command => "curl -o /tmp/moniker-$moniker_version.zip $moniker_url",
      timeout => 0,
      cwd     => "/tmp",
      creates => "/tmp/moniker-$moniker_version.zip",
      path    => ["/usr/bin", "/usr/sbin"],
      require => Package['curl'],
    }

    exec { 'unzip-moniker':
      command => "unzip /tmp/moniker-$moniker_version.zip",
      cwd     => $moniker_home,
      path    => ["/usr/bin", "/usr/sbin"],
      require => [Package['unzip'], File[$moniker_home]],
      subscribe => Exec['curl-moniker-zip'],
      refreshonly => true
    }
  }

  if $moniker_provider == 'external' {
    notify { "It's up to you to provde moniker": }
  }

  if $moniker_provider == 'git' {
    vcsrepo { $moniker_home:
      ensure   => present,
      provider => git,
      source   => "https://github.com/stackforge/moniker.git",
    }
  }
}

