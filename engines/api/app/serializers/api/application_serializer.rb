# frozen_string_literal: true

module Api
  class ApplicationSerializer
    include FastJsonapi::ObjectSerializer
    set_key_transform :camel_lower

    def initialize(object, options = {})
      super(object, ApplicationSerializer.build_options(object, options))
    end

    def hash_for_one_record
      transform_keys(super)
    end

    def hash_for_collection
      transform_keys(super)
    end

    def transform_keys(serializable_hash)
      serializable_hash[:meta] = serializable_hash
        .fetch(:meta, {})
        .transform_keys { |key| self.class.run_key_transform(key) }

      serializable_hash[:links] = serializable_hash
        .fetch(:links, {})
        .transform_keys { |key| self.class.run_key_transform(key) }

      serializable_hash
    end

    class << self
      def attributes(*attributes_list)
        attributes_list.flatten.each do |attribute_name|
          attribute attribute_name
        end
      end

      def quotation_tool?(scope:)
        scope["open_quotation_tool"] || scope["closed_quotation_tool"]
      end

      def meta(object)
        if object.respond_to? :total_pages
          {
            page: object.page,
            per_page: object.per_page,
            total_pages: object.total_pages
          }
        end
      end

      def build_options(object, options)
        meta = ApplicationSerializer.meta(object)

        options = options.merge({meta: meta}) if meta
        options = options.merge({links: object.links}) if object.respond_to? :links

        options
      end
    end
  end
end
