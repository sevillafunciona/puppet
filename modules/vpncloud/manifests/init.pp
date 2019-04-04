# class: vpncloud
class vpncloud(
        Optional[string] $server_ip = undef,
){
    file { '/opt/vpncloud_0.9.1_xenial_amd64.deb':
        ensure  => present,
        source  => 'puppet:///modules/vpncloud/vpncloud_0.9.1_xenial_amd64.deb',
    }
    
    package { 'vpncloud':
        ensure      => installed,
        provider    => dpkg,
        source      => '/opt/vpncloud_0.9.1_xenial_amd64.deb',
        require     => File['/opt/vpncloud_0.9.1_xenial_amd64.deb'],
    }

    $shared_key = hiera('passwords::vpncloud::shared_key')

    file { '/etc/vpncloud/miraheze-internal.net':
        ensure  => present,
        content  => template('vpncloud/miraheze-internal.net.erb'),
        notify  => Service['vpncloud'],
        require => Package['vpncloud'],
    }
    
    service { 'vpncloud':
        ensure      => running,
        hasrestart  => true,
        restart     => '/bin/systemctl reload vpncloud',
        require     => [ Package['vpncloud'], File['/etc/vpncloud/miraheze-internal.net'] ],
    }
}