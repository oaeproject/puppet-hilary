node 'demo' {
    $nodetype = 'demo'
    $nodesuffix = ''
    hiera_include(classes)
}

node 'qa0' {
    $nodetype = 'qa'
    $nodesuffix = 0
    hiera_include(classes)
}

node 'qa1' {
    $nodetype = 'qa'
    $nodesuffix = 1
    hiera_include(classes)
}
