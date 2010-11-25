require 'spec_helper'

describe "Geometry saver plugin" do
  before(:each) do
    small_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'small.png')
    big_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'big.jpg')
    not_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'big.zip')
    @big_image = File.open(big_path)
    @small_image = File.open(small_path)
    @big_size = Paperclip::Geometry.from_file(big_path)
    @small_size = Paperclip::Geometry.from_file(small_path)
    @not_image = File.open(not_path)
  end

  it "saves image geometry for original image" do
    img = Image.new
    img.small_image = @small_image
    img.save!

    img.reload # Ensure that updates really saved to db

    img.small_image.width eq(@small_size.width)
    img.small_image.height eq(@small_size.height)
  end

  it "saves geometry for styles" do
    img = Image.new
    img.small_image = @small_image
    img.big_image = @big_image
    img.save!

    img.big_image.width(:small).should == 100
    img.big_image.height(:small).should == 100
  end

  it "clears geometry fields when image is destroyed" do
    img = Image.new
    img.small_image = @small_image
    img.big_image = @big_image
    img.save!

    img.big_image.width(:small).should == 100

    img.big_image = nil
    img.save!

    img.big_image.width(:small).should be_nil
  end

  it "does not fails when file is not an image" do
    img = Image.new
    img.small_image = @not_image
    lambda { img.save! }.should_not raise_error
    img.small_image.width(:small).should be_nil
  end
end