# Paperclip Meta

[![Gem Version](https://badge.fury.io/rb/paperclip-meta.svg)](http://rubygems.org/gems/paperclip-meta)
[![Build Status](https://travis-ci.org/teeparham/paperclip-meta.svg?branch=master)](https://travis-ci.org/teeparham/paperclip-meta)

Add width, height, and size to paperclip images.

Paperclip Meta gets image dimensions after `post_process_styles` using paperclip's `Geometry.from_file`.

Paperclip Meta works with paperclip versions 3.x and 4.x.

### Setup

Add paperclip-meta to Gemfile:

```ruby
gem 'paperclip-meta'
```

Create migration to add a *_meta column:

```ruby
class AddAvatarMetaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_meta, :text
  end
end
```

Rebuild all thumbnails to populate the meta column if you already have some attachments.

Now you can grab the size from the paperclip attachment:

```ruby
image_tag user.avatar.url, size: user.avatar.image_size
image_tag user.avatar.url(:medium), size: user.avatar.image_size(:medium)
image_tag user.avatar.url(:thumb), size: user.avatar.image_size(:thumb)
```

### Internals

The meta column is simple hash:

```ruby
style: {
  width:  100,
  height: 100,
  size:   42000,
  fingerprint: 'b5ca2374a6cd89c4a971ddeb71f6f86d'
}
```

This hash will be marshaled and base64 encoded before writing to model attribute.

`height`, `width`, `image_size`, and `fingerprint` methods are provided:

```ruby
user.avatar.width(:thumb)
=> 100
user.avatar.height(:medium)
=> 200
user.avatar.image_size
=> '60x70'
user.avatar.fingerprint
=> 'b5ca2374a6cd89c4a971ddeb71f6f86d'
user.avatar.fingerprint(:thumb)
=> '9c0a079bdd7701d7e729bd956823d153'
```

You can pass the image style to these methods. If a style is not passed, the default style will be used.

### Alternatives

https://github.com/thoughtbot/paperclip/wiki/Extracting-image-dimensions

### Development

Test:

```sh
bundle
rake
```

Test paperclip 3.x:

```sh
BUNDLE_GEMFILE=./spec/gemfiles/Gemfile.paperclip-3 bundle
BUNDLE_GEMFILE=./spec/gemfiles/Gemfile.paperclip-3 rake
```

Test paperclip 4.x:

```sh
BUNDLE_GEMFILE=./spec/gemfiles/Gemfile.paperclip-4 bundle
BUNDLE_GEMFILE=./spec/gemfiles/Gemfile.paperclip-4 rake
```
