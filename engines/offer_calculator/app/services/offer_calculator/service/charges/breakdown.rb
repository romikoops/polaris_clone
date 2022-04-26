# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      Breakdown = Struct.new(:fee, :metadata, :delta, :source, keyword_init: true) do
        delegate :applicable, :order, :operator, to: :source, allow_nil: true
        delegate :charge_category, :cargo_class, to: :fee
        delegate :code, to: :charge_category

        def data
          fee.to_h
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
