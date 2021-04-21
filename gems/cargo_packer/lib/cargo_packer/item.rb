# frozen_string_literal: true

module CargoPacker
  class Item
    attr_reader :weight, :orientation_lock, :dimensions

    def initialize(dimensions:, weight:, stackable: true, orientation_lock: true)
      @weight = weight.to_d
      @dimensions = dimensions
      @orientation_lock = orientation_lock.nil? ? true : orientation_lock
      @stackable = stackable
    end

    delegate :width, :length, :height, :volume, :area, to: :dimensions

    def orientations
      oriented_permutations = [
        dimensions,
        Dimensions.new(length: width, width: length, height: height)
      ]
      return oriented_permutations if orientation_lock

      oriented_permutations + [
        Dimensions.new(height: width, width: height, length: length),
        Dimensions.new(height: length, width: height, length: width),
        Dimensions.new(height: width, width: height, length: length),
        Dimensions.new(height: length, width: width, length: height)
      ].sort_by(&:area).reverse
    end

    def stackable?
      @stackable
    end

    def orientation_lock?
      stackable? ? orientation_lock : true
    end
  end
end
