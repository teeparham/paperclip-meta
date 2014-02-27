require 'bundler/setup'
Bundler.require(:default)
require 'active_record'
require 'minitest/autorun'
require 'mocha/setup'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

if ENV["VERBOSE"]
  ActiveRecord::Base.logger = Logger.new(STDERR)
else
  Paperclip.options[:log] = false
end

load(File.join(File.dirname(__FILE__), 'schema.rb'))

ActiveRecord::Base.send(:include, Paperclip::Glue)
Paperclip::Meta::Railtie.insert

I18n.enforce_available_locales = true

class Image < ActiveRecord::Base
  has_attached_file :small_image,
    storage: :filesystem,
    path: "./spec/tmp/:style/:id.:extension",
    url: "./spec/tmp/:style/:id.extension"

  has_attached_file :big_image,
    storage: :filesystem,
    path: "./spec/tmp/fixtures/tmp/:style/:id.:extension",
    url: "./spec/tmp/fixtures/tmp/:style/:id.extension",
    styles: { thumb: "100x100#", large: "500x500#" }

  # paperclip 4.0 requires a validator
  validates_attachment_content_type :small_image, content_type: /\Aimage/
  validates_attachment_content_type :big_image, content_type: /\Aimage/
end

class ImageWithNoValidation < ActiveRecord::Base
  self.table_name = :images

  has_attached_file :small_image,
    storage: :filesystem,
    path: "./spec/tmp/:style/:id.:extension",
    url: "./spec/tmp/:style/:id.extension"

  if Paperclip::VERSION >= "4.0"
    do_not_validate_attachment_file_type :small_image
  end
end
