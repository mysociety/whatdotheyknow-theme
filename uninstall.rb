# Uninstall hook code here

main_app_path = File.join(RAILS_ROOT, 'public', 'alavetelitheme')
if File.exists?(main_app_path) && File.symlink?(main_app_path)
	print "Deleting symbolic link at #{main_app_path}... "
	File.delete(main_app_path)
	puts "done"
end
