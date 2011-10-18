# Install hook code here

plugin_path = File.expand_path(File.join(File.dirname(__FILE__), "public"))
main_app_path = File.join(RAILS_ROOT, 'public', 'alavetelitheme')

# If the symlink to be created exists, warn the user and do nothing
if File.exists?(main_app_path)
	puts "WARNING: #{main_app_path} already exists, the symbolic link won't be created"
else # Create symlink
	begin
		print "Creating symbolink link from #{main_app_path} to #{plugin_path}... "
		File.symlink(plugin_path, main_app_path)
		puts "done"
	rescue NotImplemented
		puts "failed: symbolic links not supported"	
	end
end