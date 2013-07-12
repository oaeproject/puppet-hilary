class localconfig::ordering::qa {
	include localconfig::ordering

	# Install the qa automation stuff after hilary is installed
    Class['::hilary'] -> Class['::oaeqaautomation']
}