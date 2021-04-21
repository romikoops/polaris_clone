# frozen_string_literal: true

module CargoPacker
  class SpaceBreaker
    attr_reader :space, :placement

    def initialize(space:, placement:)
      @space = space
      @placement = placement
    end

    def perform
      [width_space, height_space, length_space].compact
    end

    def width_space
      return if (space.width - placement.width).zero?

      Space.new(
        dimensions: Dimensions.new(
          width: space.width - placement.width,
          length: placement.length,
          height: space.height
        ),
        position: Position.new(
          width: space.position.width + placement.width,
          length: space.position.length,
          height: space.position.height
        )
      )
    end

    def height_space
      return if (space.height - placement.height).zero? || !placement.stackable?

      Space.new(
        dimensions: Dimensions.new(
          width: placement.width,
          length: placement.length,
          height: space.height - placement.height
        ),
        position: Position.new(
          width: space.position.width,
          length: space.position.length,
          height: space.position.height + placement.height
        )
      )
    end

    def length_space
      return if (space.length - placement.length).zero?

      Space.new(
        dimensions: Dimensions.new(
          width: space.width,
          length: space.length - placement.length,
          height: space.height
        ),
        position: Position.new(
          width: space.position.width,
          length: space.position.length + placement.length,
          height: space.position.height
        )
      )
    end
  end
end
