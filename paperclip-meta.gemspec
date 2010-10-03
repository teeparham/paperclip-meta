include_files = ["README*", "LICENSE", "Rakefile", "init.rb", "{lib,test}/**/*"].map do |glob|
  Dir[glob]
end.flatten

spec = Gem::Specification.new do |s|
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