ActiveRecord::Schema.define do
  create_table :images do |t|
    t.string  :small_image_file_name
    t.string  :small_image_content_type
    t.integer :small_image_updated_at
    t.integer :small_image_file_size
    t.string  :small_image_meta

    t.string  :big_image_file_name
    t.string  :big_image_content_type
    t.integer :big_image_updated_at
    t.integer :big_image_file_size
    t.string  :big_image_meta
  end
end
