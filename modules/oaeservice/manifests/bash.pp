class oaeservice::bash {
    file_line { 'ps1-bashrc':
        path => '/root/.bashrc',
        line => template('oaeservice/bash/ps1.erb'),
    }
}
