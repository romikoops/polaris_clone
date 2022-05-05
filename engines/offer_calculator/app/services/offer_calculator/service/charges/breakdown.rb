# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      Breakdown = Struct.new(:fee, :metadata, :order, keyword_init: true) do
        delegate :applicable, :operator, to: :applied_margin, allow_nil: true
        delegate :charge_category, :cargo_class, :applied_margin, to: :fee
        delegate :code, to: :charge_category

        def data
          fee.to_h
        end

        def source
          applied_margin
        end

        def target_name
          case applicable
          when Users::Client
            applicable.profile.full_name
          else
            applicable.try(:name)
          end
        end
      end
    end
  end
end
