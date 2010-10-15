module Paperclip
  module ClassMethods
    alias original_has_attached_file has_attached_file
    
    # Cache the available metadata attributes
    def has_attached_file name, options = {}
      original_has_attached_file name, options
      
      attachment_definitions.each do |name,options|
        meta_attr_cache = {}
        instance = self.new

        default_style = attachment_definitions[name][:default_style] || Attachment.default_options[:default_style]

        styles = attachment_definitions[name][:styles].keys | [ default_style ]
        styles.each do |style|
          [:width, :height, :size].each do |meth|
            if instance.respond_to?(:"#{name}_#{style}_#{meth}=")
              add_meta_attr(meta_attr_cache, style, meth, :"#{style}_#{meth}")
            end
            if style == default_style && instance.respond_to?(:"#{name}_#{meth}=")
              add_meta_attr(meta_attr_cache, style, meth, :"#{meth}")
            end
          end
        end

        attachment_definitions[name][:meta_attr_cache] = meta_attr_cache
      end
    end

    private
    def add_meta_attr(meta_attr, style, meth, value)
      meta_attr[style] ||= {}
      meta_attr[style][meth] ||= []
      meta_attr[style][meth] << value      
    end
  end

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
      meta_attr_cache = options[:meta_attr_cache]
      respond_meta = instance.respond_to?(:"#{name}_meta=")

      @queued_for_write.each do |style, file|
        if respond_meta || meta_attr_cache[style]
          [:width, :height, :size].each do |meth|
            if respond_meta
              meta[style] ||= {}
              meta[style][meth] = get_meta_from_file(file, meth)
            end
            if meta_attr_cache[style] && meta_attr_cache[style][meth]
              meta_attr_cache[style][meth].each do |attribute|
                instance_write(attribute, get_meta_from_file(file, meth))
              end
            end
          end
        end
      end
      
      if respond_meta
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
    
    def get_meta_from_file(file, method)
      @meta_file_cache ||= {}
      @meta_file_cache[file] ||= {}
      
      case method
        when :size then @meta_file_cache[file][:size] ||= File.size(file)
        when :width then (@meta_file_cache[file][:geo] ||= (Geometry.from_file file if image?)) ? @meta_file_cache[file][:geo].width.to_i : nil
        when :height then (@meta_file_cache[file][:geo] ||= (Geometry.from_file file if image?)) ? @meta_file_cache[file][:geo].height.to_i : nil
        else nil
      end
    end
    
    def image?
      !content_type.nil? and !!content_type.match(%r{\Aimage/})
    end
  end
end
