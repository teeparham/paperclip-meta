$LOAD_PATH << "." unless $LOAD_PATH.include?(".")

begin
  require "bundler"
  Bundler.setup
rescue Bundler::GemNotFound
  raise RuntimeError, "Bundler couldn't find some gems." +
    "Did you run `bundle install`?"
end

Bundler.require
require 'logger'
Paperclip::Railtie.insert

ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3", 
  "database" => ":memory:"
)

ActiveRecord::Base.logger = Logger.new(nil)

load(File.dirname(__FILE__) + '/schema.rb')
$: << File.join(File.dirname(__FILE__), '..', 'lib')

class Image < ActiveRecord::Base
  has_attached_file :small_image,
    :storage => :filesystem,
    :path => "./spec/tmp/:style/:id.:extension",
    :url => "./spec/tmp/:style/:id.extension"

  has_attached_file :big_image,
    :storage => :filesystem,
    :path => "./spec/tmp/fixtures/tmp/:style/:id.:extension",
    :url => "./spec/tmp/fixtures/tmp/:style/:id.extension",
    :styles => { :small => "100x100#" }
end