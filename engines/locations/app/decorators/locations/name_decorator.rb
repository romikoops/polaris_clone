# frozen_string_literal: true

module Locations
  class NameDecorator < SimpleDelegator
    def lat_lng
      { lat: point.x, lng: point.y }
    end
  end
end
