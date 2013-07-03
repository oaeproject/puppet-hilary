
node 'dev' {
    $nodetype = 'dev'
    $nodesuffix = 0
    hiera_include(classes)
}