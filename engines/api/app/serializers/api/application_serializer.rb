# frozen_string_literal: true

module Api
  class ApplicationSerializer
    include FastJsonapi::ObjectSerializer
    set_key_transform :camel_lower

    class << self
      def attributes(*attributes_list)
        attributes_list.flatten.each do |attribute_name|
          attribute attribute_name
        end
      end

      def quotation_tool?(scope:)
        scope['open_quotation_tool'] || scope['closed_quotation_tool']
      end
    end
  end
end
