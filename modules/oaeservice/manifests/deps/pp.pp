class oaeservice::deps::pp {
    include oaeservice::deps::common
    include oaeservice::deps::ppa::oae
    include oaeservice::deps::libreoffice

    # Necessary packages for the preview processor
    $pp_packages = [
        'pdftk',
        'chrpath',
        'pdf2htmlex',
        'libfontconfig1-dev',
        'ttf-liberation',
        'texlive-fonts-recommended',
        'fonts-international',
        'poppler-utils'
    ]
    package { $pp_packages:
        ensure   => installed
    }

    # Install some more fonts because libreoffice 4.3
    # doesn't seem to autoguess any longer
    exec { 'accept-msttcorefonts-license':
        command => '/bin/sh -c "echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections"'
    }
    package { 'ttf-mscorefonts-installer':
        ensure   => installed,
        require  => Exec['accept-msttcorefonts-license']
    }

    # Install more msfonts
    file { '/root/fonts.sh':
        content  => template('oaeservice/msfonts/fonts.sh'),
        mode     => "0755",
    }
    # Only run if there is a font missing
    exec {'/root/fonts.sh':
        creates  => '/usr/share/fonts/truetype/msttcorefonts/OpenSans-Regular.ttf',
        require  => [ File['/root/fonts.sh'], Package['ttf-mscorefonts-installer'] ]
    }
}
