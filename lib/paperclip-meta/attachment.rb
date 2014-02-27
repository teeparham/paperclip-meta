module Paperclip
  module Meta
    module Attachment
      def self.included(base)
        base.send :include, InstanceMethods
        base.alias_method_chain :save, :meta_data
        base.alias_method_chain :post_process_styles, :meta_data
        base.alias_method_chain :size, :meta_data
      end

      module InstanceMethods
        def save_with_meta_data
          if @queued_for_delete.any? && @queued_for_write.empty?
            instance_write(:meta, meta_encode({}))
          end
          save_without_meta_data
        end

        def post_process_styles_with_meta_data(*styles)
          post_process_styles_without_meta_data(*styles)
          return unless instance.respond_to?(:"#{name}_meta=")

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
          if instance.respond_to?(:"#{name}_meta") && instance_read(:meta)
            if (meta = meta_decode(instance_read(:meta)))
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
          return unless (original_meta = instance.send("#{name}_meta"))
          meta.reverse_merge! meta_decode(original_meta)
        end
      end
    end
  end
end
