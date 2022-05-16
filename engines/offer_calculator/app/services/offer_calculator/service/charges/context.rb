# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      Context = Struct.new(
        *OfferCalculator::Service::Charges::RelationData::FRAME_KEYS.map(&:to_sym),
        keyword_init: true
      ) do
        def original
          @original ||= source_type.constantize.find(context_id)
        end

        def type
          source_type
        end

        def charge_category
          @charge_category ||= Legacy::ChargeCategory.find(charge_category_id)
        end
      end
    end
  end
end
