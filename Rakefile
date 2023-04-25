require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

# task :environment do
#   require './config/environment'
# end
#
# Dir[File.dirname(__FILE__) + "/lib/tasks/**/*.rake"].sort.each do |path|
#   import path
# end
#
# Dir[File.dirname(__FILE__) + "/modules/*/lib/tasks/*.rake"].sort.each do |path|
#   import path
# end

task :default => [:test]
