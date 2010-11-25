require 'rake'
require 'rake/testtask'
require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

begin
  include_files = ["README*", "LICENSE", "Rakefile", "init.rb", "{lib,test}/**/*"].map do |glob|
    Dir[glob]
  end.flatten
  
  require "jeweler"
  Jeweler::Tasks.new do |s|
    s.name              = "paperclip-meta"
    s.version           = "0.1"
    s.author            = "Alexey Bondar"
    s.email             = "y8@ya.ru"
    s.homepage          = "http://github.com/y8/paperclip-meta"
    s.description       = "Add width, height and size methods to paperclip thumbnails"
    s.summary           = "Thumbnail dimensions for paperclip"
    s.platform          = Gem::Platform::RUBY
    s.files             = include_files
    s.require_path      = "lib"
    s.rubyforge_project = "paperclip-meta"
    s.has_rdoc          = false
    s.add_dependency 'paperclip'    
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end
