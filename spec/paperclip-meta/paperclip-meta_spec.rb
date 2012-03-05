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

  describe 'file size' do
    before do
      @image = Image.new
      @image.big_image = @big_image
      @image.save!
    end

    it 'should save file size with meta data ' do
      path = File.join(File.dirname(__FILE__), "../tmp/fixtures/tmp/small/#{@image.id}.jpg")
      size = File.stat(path).size
      @image.big_image.size(:small).should == size
    end

    it 'should access normal paperclip method when no style passed' do
      @image.big_image.should_receive(:size_without_meta_data).once.and_return(1234)
      @image.big_image.size.should == 1234
    end

    it 'should have access to original file size' do
      @image.big_image.size.should == 37042
    end

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