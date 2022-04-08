# frozen_string_literal: true

module Wheelhouse
  class QueryParamTransformationService
    attr_reader :params

    def initialize(params:)
      @params = params
    end

    def perform
      {
        selected_day: params[:cargo_ready_date] || Time.zone.today.to_s,
        cargo_items_attributes: cargo_items_attributes,
        containers_attributes: container_attributes,
        load_type: params[:load_type],
        trucking: {
          pre_carriage: {
            truck_type: params[:load_type] == "container" ? "chassis" : "default"
          },
          on_carriage: {
            truck_type: params[:load_type] == "container" ? "chassis" : "default"
          }
        },
        origin: RouteTargetParams.new(target: origin).perform,
        destination: RouteTargetParams.new(target: destination).perform,
        aggregated_cargo_attributes: aggregated_cargo_attributes,
        async: true,
        parent_id: params[:parent_id]
      }
    end

    private

    def cargo_items_attributes
      attributes_payload(
        items: params[:items].select { |item| item[:colli_type].present? }
      )
    end

    def container_attributes
      attributes_payload(
        items: params[:items].select { |item| item[:cargo_class].match?("fcl") }
      )
    end

    def attributes_payload(items:)
      items.map do |item|
        item[:payload_in_kg] = item.delete(:weight)
        item
      end
    end

    def origin
      @origin ||= Carta::Client.lookup(id: params[:origin_id])
    end

    def destination
      @destination ||= Carta::Client.lookup(id: params[:destination_id])
    end

    def aggregated_cargo_attributes
      return if params[:items].none? { |item| item[:cargo_class] == "aggregated_lcl" }

      item = params[:items].first
      item.slice(:weight, :volume, :commodities, :id).merge(stackable: true)
    end

    class RouteTargetParams
      def initialize(target:)
        @target = target
      end

      attr_reader :target

      delegate :address, :id, :type, :latitude, :longitude, :country, to: :target

      def perform
        target.to_h.slice(:address, :id).merge(mergeable_data_for_type)
      end

      def mergeable_data_for_type
        carriage? ? carriage_values : nexus_values
      end

      def carriage_values
        {
          latitude: latitude,
          longitude: longitude,
          country: country,
          full_address: address
        }
      end

      def nexus_values
        { nexus_id: nexus_id }
      end

      def nexus_id
        Legacy::Nexus.where(organization_id: Organizations.current_id, locode: address).pluck(:id).first
      end

      def carriage?
        type == "address"
      end
    end
  end
end
