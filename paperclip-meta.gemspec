require "./lib/paperclip-meta/version"

Gem::Specification.new do |s|
  s.name          = "paperclip-meta"
  s.version       = Paperclip::Meta::VERSION
  s.authors       = ["Alexey Bondar", "Tee Parham"]
  s.email         = ["y8@ya.ru", "tee@neighborland.com"]
  s.homepage      = "http://github.com/teeparham/paperclip-meta"
  s.summary       = "Add width, height, and size to paperclip images"
  s.description   = "Add width, height and size methods to paperclip images"
  s.license       = "MIT"

  s.files         = Dir["LICENSE.txt", "README.md", "lib/**/*"]
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.2.2"

  s.add_dependency "kt-paperclip", ">= 5.0"

  s.add_development_dependency "bundler", "~> 1.13"
  s.add_development_dependency "rake", "~> 12.0"
  s.add_development_dependency "mocha", "~> 1.2"
  s.add_development_dependency "activerecord", "~> 5.0"
  s.add_development_dependency "sqlite3", ">= 1.3.10"
  s.add_development_dependency "delayed_paperclip", "~> 3.0"
  s.add_development_dependency "activesupport", "~> 5.0"
  s.add_development_dependency "activejob", "~> 5.0"
  s.add_development_dependency "railties", "~> 5.0"
end
