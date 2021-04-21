# frozen_string_literal: true

module CargoPacker
  class Packer
    attr_reader :items, :container, :packings, :item_has_been_packed

    def self.pack(container:, items:)
      new(container: container, items: items).perform
    end

    def initialize(container:, items:)
      @container = container
      @items = items
    end

    def perform
      packings = sorted_item_permutations.map do |permutation|
        new_packing(permutation: permutation)
      end

      valid_packings = packings.select(&:valid?)
      raise CargoPacker::Errors::PackingFailed if valid_packings.empty?

      valid_packings.min_by(&:load_meters)
    end

    def sorted_item_permutations
      [
        items.sort_by { |item| -[item.width, item.length].max },
        items.sort_by(&:area).reverse,
        items.sort_by(&:length).reverse,
        items.sort_by(&:width).reverse
      ]
    end

    def unstackable_items
      items.reject(&:stackable?)
    end

    def new_packing(permutation:)
      packing = Packing.new(
        placements: [],
        weight: 0,
        spaces: [Space.new(
          dimensions: container.dimensions,
          position: Position.new
        )],
        container: container,
        items: permutation
      )
      permutation.each { |item| handle_packing(packing: packing, item: item) }

      packing
    end

    def handle_packing(packing:, item:)
      packing.spaces.sort_by { |space| space.position.length }.each do |space|
        # Try placing the item in this space,
        # if it doesn't fit skip on the next space
        next unless (placement = place_item(item: item, space: space))

        # Add the item to the packing and
        # break up the surrounding spaces
        packing.placements += [placement]
        packing.weight += item.weight
        packing.spaces -= [space]
        packing.spaces += SpaceBreaker.new(space: space, placement: placement).perform
        packing.spaces = SpaceCombiner.new(spaces: packing.spaces).perform
        break
      end
    end

    def place_item(item:, space:)
      correct_orientation = item.orientations.sort_by(&:length).reverse.find do |orientation|
        orientation.width <= space.width &&
          orientation.length <= space.length &&
          orientation.height <= space.height
      end
      return nil if correct_orientation.nil?

      Placement.new(
        dimensions: correct_orientation,
        position: space.position,
        item: item,
        stackable: item.stackable?
      )
    end
  end
end
