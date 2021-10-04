# frozen_string_literal: true

require "active_support/concern"

module Notifications
  module Filterable
    extend ActiveSupport::Concern

    module ClassMethods
      def filtered(filter_hash)
        self.select do |subscription|
          subscription.filter == "{}" ||
            filter_hash.any? do |filter_key, filter_list|
              filter_list.any? subscription.send(filter_key)
            end
        end
      end
    end
  end
end
