class oaeservice::deps::package::openjdk6 ($java_path = '/usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java') {

    package { 'openjdk-6-jdk':
        ensure => installed
    }

    # Note: This may intentionall conflict with the oracle java class. Only include one or the other
    alternatives { 'java':
        path => $java_path,
        require => Package['sun-java6-jre']
    }
}