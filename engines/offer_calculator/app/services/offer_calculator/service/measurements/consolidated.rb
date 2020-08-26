# frozen_string_literal: true

module OfferCalculator
  module Service
    module Measurements
      class Consolidated < OfferCalculator::Service::Measurements::Unit
        def quantity
          1
        end

        def volumetric_weight
          children.sum(Measured::Weight.new(0, "kg"), &:volumetric_weight)
        end

        def dynamic_volumetric_weight
          children.sum(Measured::Weight.new(0, "kg"), &:dynamic_volumetric_weight)
        end

        def stacked_area
          children.sum(Measured::Area.new(0, "m2"), &:stacked_area)
        end

        def children
          @children ||= cargo_children
        end
      end
    end
  end
end
