# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "paperclip-meta/version"

Gem::Specification.new do |s|
  s.name        = "paperclip-meta"
  s.version     = Paperclip::Meta::VERSION
  s.authors     = ["Alexey Bondar", "Tee Parham"]
  s.email       = ["y8@ya.ru", "tee@neighborland.com"]
  s.homepage    = "http://github.com/y8/paperclip-meta"
  s.summary     = %q{Add width, height, and size to paperclip images}
  s.description = %q{Add width, height and size methods to paperclip images}

  s.rubyforge_project = "paperclip-meta"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 1.9.3"

  s.add_dependency "paperclip", "~> 3.0"

  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "activerecord", "~> 4.0"
  s.add_development_dependency "sqlite3", "~> 1.3"
end
