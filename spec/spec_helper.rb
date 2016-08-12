require "bundler/setup"
Bundler.require(:default)
require 'rails'
require "active_record"
require "active_job"
require "delayed_paperclip"
require "delayed_paperclip/railtie"
require "minitest/autorun"
require "mocha/setup"

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

if ENV["VERBOSE"]
  ActiveRecord::Base.logger = Logger.new(STDERR)
else
  Paperclip.options[:log] = false
  ActiveJob::Base.logger = nil
end

load(File.join(File.dirname(__FILE__), "schema.rb"))

ActiveRecord::Base.send(:include, Paperclip::Glue)
Paperclip::Meta::Railtie.insert
DelayedPaperclip::Railtie.insert

I18n.enforce_available_locales = true

# suppress AR 4.2 warnings
if ActiveRecord::Base.respond_to?(:raise_in_transactional_callbacks)
  ActiveRecord::Base.raise_in_transactional_callbacks = true
end

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

  validates_attachment_content_type :small_image, content_type: /\Aimage/
  validates_attachment_content_type :big_image, content_type: /\Aimage/
end

class ImageWithNoValidation < ActiveRecord::Base
  self.table_name = :images

  has_attached_file :small_image,
    storage: :filesystem,
    path: "./spec/tmp/:style/:id.:extension",
    url: "./spec/tmp/:style/:id.extension"

  do_not_validate_attachment_file_type :small_image
end

class ImageWithDelayedPostProcessing < ActiveRecord::Base
  self.table_name = :images

  has_attached_file :big_image,
    storage: :filesystem,
    path: "./spec/tmp/fixtures/tmp/:style/:id.:extension",
    url: "./spec/tmp/fixtures/tmp/:style/:id.extension",
    styles: { thumb: "100x100#", large: "500x500#" }

  validates_attachment_content_type :big_image, content_type: /\Aimage/

  process_in_background :big_image
end
