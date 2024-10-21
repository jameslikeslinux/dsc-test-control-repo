class profile::puppet (
  Boolean $server = false,
) {
  if $server {
    $common_modules_path = [
      '/etc/puppetlabs/code/modules',
      '/opt/puppetlabs/puppet/modules',
      '/usr/share/puppet/modules'
    ]

    class { 'puppet':
      agent_server_hostname      => $trusted['certname'],
      autosign                   => true,
      environment                => 'production',
      server                     => true,
      server_common_modules_path => $common_modules_path, # avoid conflict with r10k
      server_foreman             => true,
      server_foreman_url         => 'https://foreman',
      server_reports             => 'foreman,puppetdb',
      server_storeconfigs        => true,
    }

    include puppetdb

    class { 'puppet::server::puppetdb':
      server => $trusted['certname'],
    }

    class { 'r10k':
      cachedir => '/var/r10k',
      sources  => {
        'control-repo' => {
          'remote'  => 'https://github.com/jameslikeslinux/osp-workshop-control-repo.git',
          'basedir' => '/etc/puppetlabs/code/environments',
        },
      },
    }

    include foreman::repo

    class { 'foreman_proxy':
      foreman_base_url => 'https://foreman',
      puppet           => true,
      puppetca         => false,
      trusted_hosts    => ['foreman'],
    }
  } else {
    class { 'puppet':
      agent_server_hostname => 'osp',
    }
  }
}
