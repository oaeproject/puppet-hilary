class oaeqaautomation (
        $log_file_dir = '/var/log/nightly',
        $cron_hour = 4,
        $cron_minute = 0,
    ) {

    #
    # This class sets up the necessary files and scripts to
    # automatically redeploy a QA server each night.
    #
    # The only manual intervention that is required to get clean
    # nightly QA servers is to generate a set of data after the initial
    # puppet run.
    # The nightly script will load in the same data each night,
    # this is to keep a consistent set of username/passwords and allow for
    # QA verification of identified and possibly fixed problems.
    #
    # The nightly script performs:
    #  * redeploy latest backend and front end code
    #  * minify and concatenate all the UI code.
    #  * stop all the services
    #  * remove all data in cassandra, elasticsearch, rabbitmq
    #  * start all the services back up
    #  * load in a pre-generated set of data via the model loader.
    #

    $scripts_dir = hiera('automation_scripts_dir')
    $cassandra_data_dir = hiera('db_data_dir')
    $elasticsearch_data_dir = hiera('search_data_dir')
    $user_files_dir = hiera('app_files_dir')
    $app_root_dir = hiera('app_root_dir')
    $ux_root_dir = hiera('ux_root_dir')
    $model_loader_dir = hiera('automation_model_loader_dir')
    $ui_cdn_url = hiera('ui_cdn_url', '')

    $web_domain = hiera('web_domain')
    $app_admin_tenant = hiera('app_admin_tenant', 'admin')
    $admin_host = "${app_admin_tenant}.${web_domain}"

    $flickr_api_key = hiera('automation_flickr_api_key')
    $flickr_api_secret = hiera('automation_flickr_api_secret')
    $slideshare_shared_secret = hiera('automation_slideshare_shared_secret')
    $slideshare_api_key = hiera('automation_slideshare_api_key')
    $youtube_api_key = hiera('automation_youtube_api_key')

    exec { 'mkdir_scripts': command => "mkdir -p ${scripts_dir}", unless => "test -d ${scripts_dir}" }

    # Create the nightly log file directory
    file { $log_file_dir: ensure  => directory }

    file { 'deletedata.sh':
        path => "${scripts_dir}/deletedata.sh",
        mode => 0755,
        content => template('oaeqaautomation/deletedata.sh.erb')
    }

    file { 'redeploy.sh':
        path => "${scripts_dir}/redeploy.sh",
        mode => 0755,
        content => template('oaeqaautomation/redeploy.sh.erb'),
        require => Exec['mkdir_scripts']
    }

    file { 'shutdown.sh':
        path => "${scripts_dir}/shutdown.sh",
        mode => 0755,
        content => template('oaeqaautomation/shutdown.sh.erb'),
        require => Exec['mkdir_scripts']
    }

    cron { 'clean-log-dir':
        ensure  => present,
        command => "find ${log_file_dir} -type f -mtime +5 -name \"*.log\" -delete",
        user    => 'root',
        target  => 'root',
        hour    => 0,
        minute  => 0,
    }

    $cron_log_file_path = "${log_file_dir}/`date +'\\%Y-\\%m-\\%d-\\%H-\\%M'`.log"
    cron { 'nightly-redeploy':
        ensure      => present,
        command     => "${scripts_dir}/redeploy.sh >> ${cron_log_file_path} 2>&1",
        user        => 'root',
        target      => 'root',
        hour        => $cron_hour,
        minute      => $cron_minute,
    }

    cron { 'apt-clean':
        ensure      => present,
        command     => "/usr/bin/apt-get clean >/dev/null 2>/dev/null",
        user        => 'root',
        target      => 'root',
        hour        => '*/2',
        minute      => '14',
    }

    # git clone https://github.com/oaeproject/OAE-model-loader
    vcsrepo { $model_loader_dir:
        ensure    => latest,
        provider  => git,
        source    => 'https://github.com/oaeproject/OAE-model-loader',
        revision  => 'master'
    }

    # npm install -d
    exec { "model_loader_install_npm":
        cwd         => $model_loader_dir,
        command     => 'npm install',
        logoutput   => 'on_failure',
        require     => Vcsrepo[$model_loader_dir],
  }
}
