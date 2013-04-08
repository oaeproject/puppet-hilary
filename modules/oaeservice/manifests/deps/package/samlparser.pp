class oaeservice::deps::package::samlparser {
    exec { "wget_samlparser":
        command => '/usr/bin/wget --directory-prefix=/opt http://stuff.gaeremynck.com/oae/org.sakaiproject.Hilary.SAMLParser-1.0-SNAPSHOT-jar-with-dependencies.jar',
        creates => '/opt/org.sakaiproject.Hilary.SAMLParser-1.0-SNAPSHOT-jar-with-dependencies.jar',
    }
}