class oaeservice::deps::package::samlparser {
    exec { "wget_samlparser":
        command => '/usr/bin/wget --directory-prefix=/opt https://s3.amazonaws.com/oae-releases/SAMLParser/org.sakaiproject.Hilary.SAMLParser-1.0-SNAPSHOT-jar-with-dependencies.jar',
        creates => '/opt/org.sakaiproject.Hilary.SAMLParser-1.0-SNAPSHOT-jar-with-dependencies.jar',
    }
}
