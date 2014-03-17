class oaeservice::shibboleth {
    include ::oaeservice::deps::apt::switch

    class { 'shibboleth::sp':
        entity_id               => hiera('shibboleth_entity_id'),
        keyname                 => hiera('shibboleth_keyname'),
        subjectname             => hiera('shibboleth_subjectname'),
        shibboleth_sp_host      => hiera('shibboleth_sp_host'),
    }
}
