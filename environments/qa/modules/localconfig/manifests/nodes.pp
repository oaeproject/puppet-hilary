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

node 'qa3' {
    $nodetype = 'qa'
    $nodesuffix = 3
    hiera_include(classes)
}

node 'qa4' {
    $nodetype = 'qa'
    $nodesuffix = 4
    hiera_include(classes)
}

node 'qa5' {
    $nodetype = 'qa'
    $nodesuffix = 5
    hiera_include(classes)
}

node 'unit0' {
    $nodetype = 'unit'
    $nodesuffix = 0
    hiera_include(classes)
}

node 'release0' {
    $nodetype = 'release'
    $nodesuffix = 0
    hiera_include(classes)
}

node 'puppet' {
    $nodetype = 'puppet'
    hiera_include(classes)
}