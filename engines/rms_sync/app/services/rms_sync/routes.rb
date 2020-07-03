# frozen_string_literal: true

module RmsSync
    class Routes < RmsSync::Base
      def initialize(organization_id:, sheet_type: :routes, sandbox: nil)
        super
        @book = RmsData::Book.find_or_create_by(organization: @organization, sheet_type: sheet_type)
      end

      def perform
        prepare_purge
        sync_data
        purge
      end

      def prepare_purge
        @purge_ids = @book.sheets.ids
      end

      def purge
        @book.sheets.where(id: @purge_ids).destroy_all
      end

      def sync_data
        create_sheet
        create_header_row
        create_data_cells
      end

      def itineraries
        ::Legacy::Itinerary.where(organization_id: @organization.id)
      end

      def create_sheet
        @sheet = @book.sheets.create(organization_id: @organization.id, sheet_index: 0)
      end

      def create_data_cells
        row_index = 1
        itineraries.each do |itinerary|
          pricings = itinerary.rates.empty? ? itinerary.pricings : itinerary.rates
          tenant_vehicles = pricings.map(&:tenant_vehicle).uniq
          cargo_classes = pricings.map(&:cargo_class).uniq
          tenant_vehicles.each do |tenant_vehicle|
            default_headers.each_with_index do |head, header_index|
              @sheet.cells.create!(
                cell_data(
                  itinerary: itinerary,
                  tenant_vehicle: tenant_vehicle,
                  header: head,
                  row: row_index,
                  index: header_index,
                  cargo_classes: cargo_classes
                )
              )
            end
            row_index += 1
          end
        end
      end

      def create_header_row
        default_headers.each_with_index do |head, i|
          @sheet.cells.create!(
            organization_id: @organization.id,
            row: 0,
            column: i,
            value: head
          )
        end
      end

      def default_headers
        %w(ORIGIN	COUNTRY_ORIGIN	DESTINATION	COUNTRY_DESTINATION	MOT	CARRIER	SERVICE_LEVEL TRANSIT_TIME	LCL FCL REEFER)
      end

      def cell_data(itinerary:, header:, row:, index:, tenant_vehicle:, cargo_classes:)
        obj = {
          organization_id: @organization.id,
          column: index,
          row: row
        }

        value = case header
                when 'ORIGIN'
                  hub_name(itinerary&.origin_hub)
                when 'COUNTRY_ORIGIN'
                  itinerary&.origin_hub&.address&.country&.name
                when 'DESTINATION'
                  hub_name(itinerary&.destination_hub)
                when 'COUNTRY_DESTINATION'
                  itinerary&.destination_hub&.address&.country&.name
                when 'MOT'
                  itinerary&.mode_of_transport
                when 'CARRIER'
                  tenant_vehicle&.carrier&.name
                when 'SERVICE_LEVEL'
                  tenant_vehicle&.name
                when 'TRANSIT_TIME'
                  trip = itinerary.trips.first
                  ((trip.end_date - trip.start_date) / 86400).to_i
                when 'LCL'
                  cargo_classes.include?('lcl').to_s
                when 'FCL'
                  cargo_classes.any? { |cc| cc.include?('fcl') }.to_s
                when 'REEFER'
                  cargo_classes.any? { |cc| cc.include?('_rf') }.to_s
                end

        obj[:value] = value.present? ? value : nil

        obj
      end
      attr_accessor :purge_ids, :book
    end
end
