require 'spec_helper'

describe "Attachment" do
  it "saves image geometry for original image" do
    img = Image.create(small_image: small_image)
    img.reload
    geometry = geometry_for(small_path)
    assert_equal geometry.width, img.small_image.width
    assert_equal geometry.height, img.small_image.height
  end

  it "saves geometry for styles" do
    img = Image.create(small_image: small_image, big_image: big_image)
    assert_equal 100, img.big_image.width(:thumb)
    assert_equal 100, img.big_image.height(:thumb)
  end

  it "sets geometry on update" do
    img = Image.create!
    img.small_image = small_image
    img.save
    geometry = geometry_for(small_path)
    assert_equal geometry.width, img.small_image.width
    assert_equal geometry.height, img.small_image.height
  end

  describe 'file size' do
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

  it "doesn't overwrite all metadata if reprocessing specific style" do
    img             = Image.new
    img.big_image   = big_image
    img.save!

    assert_equal 500, img.big_image.width(:large)

    img.big_image.reprocess!(:thumb)

    assert_equal 500, img.big_image.width(:large)
  end

  it "doesn't allow nils as meta when styles change" do
    img = Image.new
    img.big_image = big_image
    img.save!

    # Simulating a new style added later that hasn't been processed
    # and is nullified
    og_meta = img.big_image.send(:meta_decode, img.big_image_meta)
    og_meta[:thumb] = nil
    encoded = img.big_image.send(:meta_encode, og_meta)
    img.update_column(:big_image_meta, encoded)

    # Next update of meta
    img.big_image.send(:write_meta, {thumb: {}})
    img.save!

    meta = img.big_image.send(:meta_decode, img.big_image_meta)
    assert_equal Hash.new, meta[:thumb]
  end

  private

  def small_path
    File.join(File.dirname(__FILE__), 'fixtures', 'small.png')
  end

  def small_image
    File.open(small_path)
  end

  def geometry_for(path)
    Paperclip::Geometry.from_file(path)
  end

  def big_image
    File.open(File.join(File.dirname(__FILE__), 'fixtures', 'big.jpg'))
  end

  def not_image
    File.open(File.join(File.dirname(__FILE__), 'fixtures', 'big.zip'))
  end
end
