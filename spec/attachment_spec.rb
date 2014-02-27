require 'spec_helper'

describe "Attachment" do
  it "saves image geometry for original image" do
    img = Image.create(small_image: small_image)
    img.reload
    geometry = geometry_for(small_path)
    assert_equal geometry.width, img.small_image.width
    assert_equal geometry.height, img.small_image.height
    assert_equal "50x64", img.small_image.image_size
  end

  it "saves geometry for styles" do
    img = Image.create(small_image: small_image, big_image: big_image)
    assert_equal 100, img.big_image.width(:thumb)
    assert_equal 100, img.big_image.height(:thumb)
  end

  it "saves original style geometry" do
    img = Image.create(small_image: small_image)
    assert_equal 50, img.small_image.width(:original)
    assert_equal 64, img.small_image.height(:original)
  end

  it "sets geometry on update" do
    img = Image.create!
    img.small_image = small_image
    img.save
    geometry = geometry_for(small_path)
    assert_equal geometry.width, img.small_image.width
    assert_equal geometry.height, img.small_image.height
  end

  describe '#size' do
    before do
      @image = Image.create(big_image: big_image)
    end

    it 'should save file size with meta data ' do
      path = File.join(File.dirname(__FILE__), "tmp/fixtures/tmp/thumb/#{@image.id}.jpg")
      size = File.stat(path).size
      assert_equal size, @image.big_image.size(:thumb)
    end

    it 'should access normal paperclip method when no style passed' do
      @image.big_image.expects size_without_meta_data: 1234
      assert_equal 1234, @image.big_image.size
    end

    it 'should have access to original file size' do
      assert_equal 37042, @image.big_image.size
    end
  end

  it "clears geometry fields when image is destroyed" do
    img = Image.create(small_image: small_image, big_image: big_image)
    assert_equal 100, img.big_image.width(:thumb)
    img.big_image = nil
    img.save!
    assert_nil img.big_image.width(:thumb)
  end

  it "does not save when file is not an image" do
    img = Image.new
    img.small_image = not_image
    refute img.save
    assert_nil img.small_image.width
  end

  it "returns nil attributes when file is not an image" do
    img = ImageWithNoValidation.new
    img.small_image = not_image
    img.save!
    assert_nil img.small_image.width
    assert_nil img.small_image.height
  end

  it "preserves metadata when reprocessing a specific style" do
    img = Image.new
    img.big_image = big_image
    img.save!
    assert_equal 500, img.big_image.width(:large)
    img.big_image.reprocess!(:thumb)
    assert_equal 500, img.big_image.width(:large)
  end

  it "preserves metadata for unprocessed styles" do
    img = Image.new
    img.big_image = big_image
    img.save!

    # set big image meta to fake values for :large & missing :thumb
    hash = { large: { height: 1, width: 2, size: 3 } }
    img.update_column(:big_image_meta, img.big_image.send(:meta_encode, hash))

    assert_equal 1, img.big_image.height(:large)
    assert_equal 2, img.big_image.width(:large)
    assert_equal 3, img.big_image.size(:large)
    assert_nil img.big_image.height(:thumb)
    assert_nil img.big_image.height(:original)
    img.big_image.reprocess!(:thumb)
    assert_equal 1, img.big_image.height(:large)
    assert_equal 2, img.big_image.width(:large)
    assert_equal 3, img.big_image.size(:large)
    assert_equal 100, img.big_image.height(:thumb)
    assert_equal 100, img.big_image.width(:thumb)
    assert_equal 277, img.big_image.height(:original) # original is always reprocessed
  end

  it "replaces metadata when attachment changes" do
    img = Image.new
    img.big_image = big_image
    img.save!
    img.big_image = small_image
    img.save!
    assert_equal "50x64", img.big_image.image_size
    assert_equal "100x100", img.big_image.image_size(:thumb)
    assert_equal "500x500", img.big_image.image_size(:large)
  end

  private

  def small_path
    File.join(File.dirname(__FILE__), 'fixtures', 'small.png')
  end

  # 50x64
  def small_image
    File.open(small_path)
  end

  def geometry_for(path)
    Paperclip::Geometry.from_file(path)
  end

  # 600x277
  def big_image
    File.open(File.join(File.dirname(__FILE__), 'fixtures', 'big.jpg'))
  end

  def not_image
    File.open(File.join(File.dirname(__FILE__), 'fixtures', 'big.zip'))
  end
end
