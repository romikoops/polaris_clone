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

        def load_meterage_limit(type:)
          send(["load_meterage", type, "limit"].join("_"))
        end

        def load_meterage_type(type:)
          send(["load_meterage", type, "type"].join("_")) || "none"
        end
      end
    end
  end
end
