node 'demo' {
    $nodetype = 'demo'
    $nodesuffix = ''
    hiera_include(classes)
}