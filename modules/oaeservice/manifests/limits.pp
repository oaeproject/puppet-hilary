class oaeservice::limits (
        $sys_max_files          = '50367',      # System-wide max open files (OS Default: 50367)
        $sys_max_map            = '65536',      # System-wide max memory map areas per process (OS Default: 65536)

        $user_soft_max_files    = '1024',       # User-level max open files per user (OS Default: 1024)
        $user_hard_max_files    = '4096',       # User-wide max open files (OS Default: 4096)
        $user_soft_memlock      = '64',         # User-level max locked memory per user (kb) (OS Default: 64)
        $user_hard_memlock      = '64',         # User-wide max locked memory (kb) (OS Default: 64)
    ) {

    include ulimit

    sysctl { 'fs.file-max':         val => $sys_max_files }
    sysctl { 'vm.max_map_count':    val => $sys_max_map }

    ulimit::rule {
        'soft_max_files':
            ulimit_domain => '*',
            ulimit_type   => 'soft',
            ulimit_item   => 'nofile',
            ulimit_value  => $user_soft_max_files;

        'hard_max_files':
            ulimit_domain => '*',
            ulimit_type   => 'hard',
            ulimit_item   => 'nofile',
            ulimit_value  => $user_hard_max_files;

        'soft_max_files_root':
            ulimit_domain => 'root',
            ulimit_type   => 'soft',
            ulimit_item   => 'nofile',
            ulimit_value  => $user_soft_max_files;

        'hard_max_files_root':
            ulimit_domain => 'root',
            ulimit_type   => 'hard',
            ulimit_item   => 'nofile',
            ulimit_value  => $user_hard_max_files;

        'soft_memlock':
            ulimit_domain => '*',
            ulimit_type   => 'soft',
            ulimit_item   => 'memlock',
            ulimit_value  => $user_soft_memlock;

        'hard_memlock':
            ulimit_domain => '*',
            ulimit_type   => 'hard',
            ulimit_item   => 'memlock',
            ulimit_value  => $user_hard_memlock;

        'soft_memlock_root':
            ulimit_domain => 'root',
            ulimit_type   => 'soft',
            ulimit_item   => 'memlock',
            ulimit_value  => $user_soft_memlock;

        'hard_memlock_root':
            ulimit_domain => 'root',
            ulimit_type   => 'hard',
            ulimit_item   => 'memlock',
            ulimit_value  => $user_hard_memlock;
    }
}