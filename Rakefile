require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs << 'spec'
  t.test_files = %w(spec/**/*_spec.rb)
  t.verbose = false
end

task default: :spec
