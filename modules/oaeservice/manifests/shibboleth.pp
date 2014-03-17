class oaeservice::shibboleth {
    class { 'shibboleth::sp':
        entity_id               => hiera('shibboleth_entity_id'),
        keyname                 => hiera('shibboleth_keyname'),
        subjectname             => hiera('shibboleth_subjectname'),
        shibboleth_hosts        => hiera('shibboleth_hosts', {}),
        app_hosts               => hiera('app_hosts')
    }
}
