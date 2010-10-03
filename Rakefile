require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc "Build the gem into the current directory"
task :gem => :gemspec do
  `gem build #{spec.name}.gemspec`
end
