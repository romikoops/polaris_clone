# frozen_string_literal: true

module CargoPacker
  class SpaceCombiner
    attr_reader :spaces, :placement

    def initialize(spaces:)
      @spaces = spaces
    end

    def perform
      spaces.each do |space|
        combine(space: space)
      end
      spaces
    end

    def combine(space:)
      new_space = (spaces - [space]).find do |other_space|
        merge(space: space, other_space: other_space)
      end
      return if new_space.nil?

      combine(space: new_space)
    end

    def adjacent_left?(space:, other_space:)
      space.position.width + space.width == other_space.position.width &&
        space.position.length == other_space.position.length &&
        space.position.height == other_space.position.height &&
        space.dimensions.height == other_space.dimensions.height &&
        space.dimensions.length == other_space.dimensions.length
    end

    def adjacent_front?(space:, other_space:)
      space.position.width == other_space.position.width &&
        space.position.length + space.length == other_space.position.length &&
        space.position.height == other_space.position.height &&
        space.dimensions.height == other_space.dimensions.height &&
        space.dimensions.width == other_space.dimensions.width
    end

    def merge(space:, other_space:)
      width, length = if adjacent_left?(space: space, other_space: other_space)
        [space.width + other_space.width, space.length]
      elsif adjacent_front?(space: space, other_space: other_space)
        [space.width, space.length + other_space.length]
      else
        []
      end

      return if width.nil?

      merged_space = Space.new(
        position: space.position,
        dimensions: Dimensions.new(
          width: width,
          length: length,
          height: space.height
        )
      )
      @spaces = (spaces - [space, other_space]) + [merged_space]

      merged_space
    end
  end
end
