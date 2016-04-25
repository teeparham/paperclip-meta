module Paperclip
  module Meta
    module Attachment
      @@default_meta_data_attribute = :meta

      def self.default_meta_data_attribute
        @@default_meta_data_attribute
      end
      
      def self.default_meta_data_attribute=(attrib)
        @@default_meta_data_attribute = attrib
      end
      
      def self.included(base)
        base.send :include, InstanceMethods
        base.extend ClassMethods
        base.alias_method_chain :save, :meta_data
        base.alias_method_chain :post_process_styles, :meta_data
        base.alias_method_chain :size, :meta_data
      end

      module InstanceMethods
        def meta_data_attribute
          if instance.respond_to?(:meta_data_attribute) 
            instance.meta_data_attribute
          else
            Paperclip::Meta::Attachment.default_meta_data_attribute
          end
        end
        
        def save_with_meta_data
          if @queued_for_delete.any? && @queued_for_write.empty?
            instance_write(meta_data_attribute, meta_encode({}))
          end
          save_without_meta_data
        end

        def post_process_styles_with_meta_data(*styles)
          post_process_styles_without_meta_data(*styles)
          return unless instance_respond_to?(meta_data_attribute)

          meta = populate_meta(@queued_for_write)
          return if meta == {}

          write_meta(meta)
        end

        # Use meta info for style if required
        def size_with_meta_data(style = nil)
          style ? read_meta(style, :size) : size_without_meta_data
        end

        def height(style = default_style)
          read_meta style, :height
        end

        def width(style = default_style)
          read_meta style, :width
        end

        def aspect_ratio(style = default_style)
          width(style).to_f / height(style).to_f
        end

        # Return image dimesions ("WxH") for given style name. If style name not given,
        # return dimesions for default_style.
        def image_size(style = default_style)
          "#{width(style)}x#{height(style)}"
        end

        private

        def populate_meta(queue)
          meta = {}
          queue.each do |style, file|
            begin
              geo = Geometry.from_file file
              meta[style] = { width: geo.width.to_i, height: geo.height.to_i, size: file.size }
            rescue Paperclip::Errors::NotIdentifiedByImageMagickError
              meta[style] = {}
            end
          end
          meta
        end

        def write_meta(meta)
          merge_existing_meta_hash meta
          instance.send("#{name}_meta=", meta_encode(meta))
        end

        # Return meta data for given style
        def read_meta(style, item)
          if instance_read(meta_data_attribute)
            if (meta = meta_decode(instance_read(meta_data_attribute)))
              meta[style] && meta[style][item]
            end
          end
        end

        # Return encoded metadata as String
        def meta_encode(meta)
          Base64.encode64(Marshal.dump(meta))
        end

        # Return decoded metadata as Object
        def meta_decode(meta)
          Marshal.load(Base64.decode64(meta))
        end

        # Retain existing meta values that will not be recalculated when
        # reprocessing a subset of styles
        def merge_existing_meta_hash(meta)
          return unless (original_meta = instance_read(meta_data_attribute))
          meta.reverse_merge! meta_decode(original_meta)
        end
      end
    end
  end
end
