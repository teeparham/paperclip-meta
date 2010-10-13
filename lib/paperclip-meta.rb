module Paperclip
  class Attachment
    alias original_post_process_styles post_process_styles

    # If model has #{name}_meta column we getting sizes of processed
    # thumbnails and saving it to #{name}_meta column.
    #
    # Also save the value in #{name}[_#{style}]_#{method} if it exists
    #  (method is width|height|size)
    def post_process_styles
      original_post_process_styles
      
      meta = {}

      @queued_for_write.each do |style, file|
        meta[style] = {}
        [:width, :height, :size].each do |meth|
          if (value = get_meta_from_file(file, meth))
            meta[style][meth] = value
            if instance.respond_to?(:"#{name}_#{style}_#{meth}=")
              instance_write(:"#{style}_#{meth}", value)
            end
            if style == default_style && instance.respond_to?(:"#{name}_#{meth}=")
              instance_write(:"#{meth}", value)
            end
          end
        end
      end
      
      if instance.respond_to?(:"#{name}_meta=")
        instance_write(:meta, ActiveSupport::Base64.encode64(Marshal.dump(meta)))
      end
    end

    # Meta access methods
    [:width, :height, :size].each do |meth|
      define_method(meth) do |*args|
        style = args.first || default_style
        meta_read(style, meth)
      end
    end

    def image_size(style = default_style)
      "#{width(style)}x#{height(style)}"
    end

    private
    def meta_read(style, item)
      if instance.respond_to?(:"#{name}_#{style}_#{item}") && instance_read(:"#{style}_#{item}")
        instance_read(:"#{style}_#{item}")
      elsif style == default_style && instance.respond_to?(:"#{name}_#{item}") && instance_read(:"#{item}")
        instance_read(:"#{item}")
      elsif instance.respond_to?(:"#{name}_meta") && instance_read(:meta)
        if meta = Marshal.load(ActiveSupport::Base64.decode64(instance_read(:meta)))
          meta.key?(style) ? meta[style][item] : nil
        end
      end
    end
    
    def image?
      !content_type.nil? and !!content_type.match(%r{\Aimage/})
    end
    
    def get_meta_from_file(file, method)
      case method
        when :size then File.size(file)
        when :width then image? ? Geometry.from_file(file).width.to_i : nil
        when :height then image? ? Geometry.from_file(file).height.to_i : nil
        else nil
      end
    end
  end
end
