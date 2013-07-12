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

node 'qa2' {
    $nodetype = 'qa'
    $nodesuffix = 2
    hiera_include(classes)
}

node 'unit0' {
    $nodetype = 'unit'
    $nodesuffix = 0
    hiera_include(classes)
}