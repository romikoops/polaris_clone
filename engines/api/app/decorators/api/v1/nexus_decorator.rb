# frozen_string_literal: true

module Api
  module V1
    class NexusDecorator < Draper::Decorator
      decorates 'Legacy::Nexus'

      delegate_all
      delegate :name, to: :country, prefix: true

      def modes_of_transport
        hubs.pluck(:hub_type)
      end
    end
  end
end
