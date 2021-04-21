# frozen_string_literal: true

module CargoPacker
  class Service
    attr_reader :items, :container, :options

    CONTAINER_HEIGHT = 2.2
    LOAD_METERAGE_DIVISOR = 2.4

    def self.pack(items:, options: {})
      new(items: items, options: options).perform
    end

    def initialize(items:, options: {})
      @items = items
      @options = options
    end

    def perform
      Packer.pack(container: packer_container, items: packer_items)
    end

    def packer_items
      @packer_items ||= items.flat_map do |item|
        Array.new(item.fetch(:quantity, 1)) do
          Item.new(
            dimensions: Dimensions.new(
              width: item[:width],
              length: item[:length],
              height: item[:height]
            ),
            weight: item[:weight],
            orientation_lock: item[:orientation_lock],
            stackable: item[:stackable]
          )
        end
      end
    end

    def packer_container
      Container.new(
        dimensions: Dimensions.new(
          width: container_width,
          length: container_length,
          height: container_height_limit
        ),
        load_meterage_divisor: load_meterage_divisor
      )
    end

    def container_width
      packer_items.flat_map { |item| [item.width, item.length] }.max
    end

    def container_length
      packer_items.sum { |item| [item.width, item.length].max }
    end

    def container_height_limit
      options[:height_limit] || CONTAINER_HEIGHT
    end

    def load_meterage_divisor
      options[:load_meterage_divisor] || LOAD_METERAGE_DIVISOR
    end
  end
end
