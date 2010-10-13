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
        meta[style] = { :size => File.size(file) }
        if image?
          geo = Geometry.from_file file
          meta[style][:width] = geo.width.to_i
          meta[style][:height] = geo.height.to_i
        end
        
        [:width, :height, :size].each do |meth|
          if (meta[style][meth])
            if instance.respond_to?(:"#{name}_#{style}_#{meth}=")
              instance_write(:"#{style}_#{meth}", meta[style][meth])
            end
            if style == default_style && instance.respond_to?(:"#{name}_#{meth}=")
              instance_write(:"#{meth}", meta[style][meth])
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
  end
end
