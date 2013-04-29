module Paperclip
  module Meta
    module Attachment
      # Use Base64 class if aviliable, to prevent
      # ActiveSupport deprecation warnings.
      begin
        require "base64"
      rescue LoadError
        Base64 = ActiveSupport::Base64
      end

      def self.included(base)
        base.send :include, InstanceMethods
        base.alias_method_chain :save, :meta_data
        base.alias_method_chain :post_process_styles, :meta_data
        base.alias_method_chain :size, :meta_data
      end

      module InstanceMethods

        def save_with_meta_data
          if (not @queued_for_delete.empty?) and @queued_for_write.empty?
            instance_write(:meta, meta_encode({})) if instance.respond_to?(:"#{name}_meta=")
          end
          save_without_meta_data
        end

        def post_process_styles_with_meta_data(*style_args)
          post_process_styles_without_meta_data(*style_args)

          if instance.respond_to?(:"#{name}_meta=")
            meta = populate_meta(@queued_for_write)
            write_meta(meta)
          end
        end

        def populate_meta(queue)
          meta = {}
          queue.each do |style, file|
            begin
              geo = Geometry.from_file file
              meta[style] = {:width => geo.width.to_i, :height => geo.height.to_i, :size => file.size }
            rescue Paperclip::Errors::NotIdentifiedByImageMagickError => e
              meta[style] = {}
            end
          end

          meta
        end

        def retain_meta(meta)
          # retrieves the original metadata for that name
          original_meta = instance.send("#{name}_meta")
          decoded_original_meta = meta_decode(original_meta) if original_meta

          # if original meta exists replace old metadata with new metadata
          # retains metadata relating to other styles that may not be processed on exclusive reprocess
          if decoded_original_meta
            all_styles.each do |style|
              # if a metadata for that style already exists
              unless meta[style].present?
                meta[style] = decoded_original_meta[style]
              end
            end
          end
        end

        def write_meta(meta)
          retain_meta(meta)

          unless meta == {}
            instance.send("#{name}_meta=", meta_encode(meta))
            instance.class.where(instance.class.primary_key => instance.id).update_all({ "#{name}_meta" => meta_encode(meta) })
          end
        end

        def all_styles
          self.styles.keys.prepend(:original)
        end

        #Use meta info for style if required
        def size_with_meta_data(passed_style = nil)
          passed_style ? meta_read(passed_style, :size) : size_without_meta_data
        end

        # Define meta accessors methods
        [:width, :height ].each do |meth|
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
          Base64.encode64(Marshal.dump(meta))
        end

        # Return decoded metadata as Object
        def meta_decode(meta)
          Marshal.load(Base64.decode64(meta))
        end
      end
    end
  end
end
