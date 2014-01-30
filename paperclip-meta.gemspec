# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "paperclip-meta/version"

Gem::Specification.new do |s|
  s.name        = "paperclip-meta"
  s.version     = Paperclip::Meta::VERSION
  s.authors     = ["Alexey Bondar"]
  s.email       = ["y8@ya.ru"]
  s.homepage    = "http://github.com/y8/paperclip-meta"
  s.summary     = %q{Thumbnail dimensions for paperclip}
  s.description = %q{Add width, height and size methods to paperclip thumbnails}

  s.rubyforge_project = "paperclip-meta"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Development depensencies
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "activerecord"
  s.add_development_dependency "activerecord-jdbcsqlite3-adapter" if RUBY_PLATFORM == 'java'
  s.add_development_dependency "sqlite3-ruby"

  # Runtime dependencies
  s.add_runtime_dependency "paperclip"
end
