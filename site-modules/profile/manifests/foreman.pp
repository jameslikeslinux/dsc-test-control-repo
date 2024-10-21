class profile::foreman {
  include foreman::repo
  include foreman

  # Only manage Puppet plugin after initial Foreman installation
  if $facts['foreman_dynflow'] {
    # Not strictly required, but it enables Puppet support for
    # `foreman::plugin::puppet` before foreman_proxy is managed
    # on the real Puppet Server.
    class { 'foreman_proxy':
      puppet   => true,
      puppetca => false,
    }

    include 'foreman::plugin::puppet'
  }

  group { 'puppet':
    system => true,
  }

  user { 'puppet':
    gid    => 'puppet',
    system => true,
  }

  # Foreman uses Puppet keys by default; make them readable
  file { '/etc/puppetlabs/puppet/ssl':
    owner   => 'puppet',
    group   => 'puppet',
    recurse => true,
    before  => Class['foreman'],
  }
}
