class oaeservice::deps::common {
    include ::apt

    Class['::apt::update'] -> Package <| title != "python-software-properties" and title != "software-properties-common" |>

    package { 'build-essential': ensure => installed }
    package { 'automake': ensure => installed }
    package { 'libssl-dev': ensure => installed }
    package { 'bsd-mailx': ensure => installed }

    include ::oaeservice::deps::package::git

    # Automatically install security updates
    class { '::apt::unattended_upgrades':
        origins             => $::apt::params::origins,
        blacklist           => [],

        # Update, download and upgrade daily
        update              => '1',
        download            => '1',
        upgrade             => '1',

        # Clean apt's cache every week
        autoclean           => '7',

        # Do NOT reboot automatically
        auto_reboot         => false,

        # Do NOT install updates on shutdown
        install_on_shutdown => false,

        # Send an email if some of the updates could not be applied
        # or if they require an email
        mail_to             => "oae-monitoring@googlegroups.com",
        mail_only_on_error  => true,
    }
}
