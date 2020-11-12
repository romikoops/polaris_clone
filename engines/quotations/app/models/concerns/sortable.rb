# app/models/concerns/sortable.rb
require "active_support/concern"

module Sortable
  extend ActiveSupport::Concern
  module ClassMethods
    attr_reader :sorted_scopes

    def sorted(sort_by:, direction:)
      respond_to?("sorted_by_#{sort_by}".to_sym) ? public_send("sorted_by_#{sort_by}", direction) : all
    end
  end
end
