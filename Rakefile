##
# To run theme rake tasks from the core Alaveteli directory you need to:
#   rails -f lib/themes/whatdotheyknow-theme/Rakefile <task>
#
require "#{ENV['PWD']}/config/application"

Rails.application.load_tasks

Dir[File.join(__dir__, 'lib', 'tasks', '*.rake')].each { |file| load(file) }
