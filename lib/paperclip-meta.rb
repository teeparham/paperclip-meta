module Paperclip
  class Attachment
    alias :original_post_process_styles :post_process_styles
    alias :original_save :save

    # If attachment deleted - destroy meta data
    def save
      if (not @queued_for_delete.empty?) and @queued_for_write.empty?
        instance_write(:meta, meta_encode({})) if instance.respond_to?(:"#{name}_meta=")
      end
      original_save
    end

    # If model has #{name}_meta column we getting sizes of processed
    # thumbnails and saving it to #{name}_meta column.
    def post_process_styles(*style_args)
      # Check arity of :original_post_process_styles to maintain compatibility with
      # Paperclip 2.3.9 and older.
      method(:original_post_process_styles).arity == 0 ? original_post_process_styles : original_post_process_styles(*style_args)

      if instance.respond_to?(:"#{name}_meta=")
        meta = {}

        @queued_for_write.each do |style, file|
          begin
            geo = Geometry.from_file file
            meta[style] = {:width => geo.width.to_i, :height => geo.height.to_i, :size => File.size(file) }
          rescue NotIdentifiedByImageMagickError => e
            meta[style] = {}
          end
        end

        instance_write(:meta, meta_encode(meta))
      end
    end

    # Define meta accessors methods
    [:width, :height, :size].each do |meth|
      define_method(meth) do |*args|
        style = args.first || default_style
        meta_read(style, meth)
      end
    end

    # Returns image dimesions ("WxH") for given style name. If style name not given,
    # returns dimesions for default_style.
    def image_size(style = default_style)
      "#{width(style)}x#{height(style)}"
    end

    private
    # Returns meta data for given style
    def meta_read(style, item)
      if instance.respond_to?(:"#{name}_meta") && instance_read(:meta)
        if meta = meta_decode(instance_read(:meta))
          meta.key?(style) ? meta[style][item] : nil
        end
      end
    end

    # Return encoded metadata as String
    def meta_encode(meta)
      # Use Base64 class if aviliable, to prevent
      # ActiveSupport deprecation warnings.
      if Module.const_defined? "Base64"
        ::Base64.encode64(Marshal.dump(meta))
      else
       ActiveSupport::Base64.encode64(Marshal.dump(meta))
      end
    end

    # Return decoded metadata as Object
    def meta_decode(meta)
      # Use Base64 class if aviliable, to prevent
      # ActiveSupport deprecation warnings.
      if Module.const_defined? "Base64"
        Marshal.load(::Base64.decode64(meta))
      else
        Marshal.load(ActiveSupport::Base64.decode64(meta))
      end
    end
  end
end
