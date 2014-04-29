define shibboleth::vhost (
    $hostname,
    $remote_user
) {

    apache::vhost { $hostname:
        port => '8080',

        # We need to pass the url the user arrived at
        servername => "http://${hostname}:80",

        # Unfortunately, the `docroot` parameter is required by the apache::vhost module
        # It's not exposed to users anywhere though
        docroot => '/opt/3akai-ux',

        # apache::vhost's other parameters have some support for proxy passing and Location blocks
        # but not in the way we need it. Therefor we use a custom fragment
        custom_fragment => template('shibboleth/apache_vhost.erb'),
    }
}
