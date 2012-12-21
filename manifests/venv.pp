
#
# TODO: stop using hard coded paths. move them to moniker::config
class moniker::venv {
  include python::dev
  include python::venv

  # virtual env for moniker
  Exec { path => "/usr/sbin:/usr/bin:/sbin:/bin" }

  python::venv::isolate { "/opt/stack/moniker":
    requirements => ["/opt/stack/moniker/tools/setup-requires",
                      '/opt/stack/moniker/tools/pip-requires',
                      '/opt/stack/moniker/tools/pip-options'],
    require => Class['moniker::package'],
  }

  class { 'moniker::package':
    moniker_home => '/opt/stack/moniker'
  }
}
