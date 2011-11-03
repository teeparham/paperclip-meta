module Paperclip
  class Attachment
    alias :original_post_process_styles :post_process_styles
    alias :original_save :save

    # If attachment deleted - destroy meta data
    def save
      if (not @queued_for_delete.empty?) and @queued_for_write.empty?
        instance_write(:meta, ActiveSupport::Base64.encode64(Marshal.dump({}))) if instance.respond_to?(:"#{name}_meta=")
      end
      original_save
    end
      
    # If model has #{name}_meta column we getting sizes of processed
    # thumbnails and saving it to #{name}_meta column.
    def post_process_styles
      original_post_process_styles

      if instance.respond_to?(:"#{name}_meta=")
        meta = {}

        @queued_for_write.each do |style, file|
          meta[style] = meta_calc_style(style, file)
        end

        instance_write(:meta, ActiveSupport::Base64.encode64(Marshal.dump(meta)))
      end
    end

    def meta_calc_style(style, file = nil)
      meta = {}

      if file == nil
        file = self.path(style)
      end

      begin
        geo = Geometry.from_file file
        meta = {:width => geo.width.to_i, :height => geo.height.to_i, :size => File.size(file) }
        meta[:md5] = Digest::MD5.file(file).to_s
      rescue NotIdentifiedByImageMagickError => e
        meta = {:image_magick_failure => true}
        meta[:md5] = Digest::MD5.file(file).to_s
      end
        
      meta
    end

    # Meta access methods
    [:width, :height, :size, :md5].each do |meth|
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
      if instance.respond_to?(:"#{name}_meta") && instance_read(:meta)
        if meta = Marshal.load(ActiveSupport::Base64.decode64(instance_read(:meta)))
          if meta.key?(style)
            value = meta[style][item]
            if value != nil
              value
            else
              if !meta[style][:image_magick_failure] || item != :md5
                meta[style] = meta_calc_style(style)[item]
                instance_write(:meta, ActiveSupport::Base64.encode64(Marshal.dump(meta)))
              end
              meta[style][item]
            end
          else
            if self.styles.include?(style)
              meta[style] = meta_calc_style(style)[item]
              instance_write(:meta, ActiveSupport::Base64.encode64(Marshal.dump(meta)))
              meta[style][item]
            else
              nil
            end
          end
        end
      end
    end    
  end
end
