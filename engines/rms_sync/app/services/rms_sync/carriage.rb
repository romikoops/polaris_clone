# frozen_string_literal: true

module RmsSync
  class Carriage < RmsSync::Base

    def initialize(organization_id:, sheet_type: :carriage)
      super
      @book = RmsData::Book.find_or_create_by(organization: @organization, sheet_type: sheet_type)
      @hash = Hash.new { |h, k| h[k] = {} }
    end

    def perform
      prepare_purge
      sync_data
      import_cells
      purge
    end

    def prepare_purge
      @purge_ids = @book.sheets.ids
    end

    def purge
      @book.sheets.where(id: @purge_ids).destroy_all
    end

    def import_cells
      RmsData::Cell.import(@cells, validate_uniqueness: true)
    end

    def sync_data
      prep_data
      write_sheets
      import_cells
    end

    def hubs_by_country
      ::Legacy::Hub.where(organization_id: @organization.id).group_by { |h| h.address&.country&.code }
    end

    def create_sheet(index:, name: '', metadata: {})
      @book.sheets.create(organization_id: @organization.id, sheet_index: index, name: name, metadata: metadata)
    end

    def write_sheets
      sheet_index = 0
      @hash.each do |country_code, courier_data|
        courier_data.each do |tenant_vehicle_id, data|
          courier = ::Legacy::TenantVehicle.find(tenant_vehicle_id)
          @sheet = create_sheet(
            index: sheet_index,
            name: courier&.name,
            metadata: { 
              tenant_vehicle_id: tenant_vehicle_id,
              courier_name: courier&.name,
              modifier: data[:modifier]
            }
          )
          write_cell(@sheet, 0, 0, country_code.upcase)
          data[:hubs].each_with_index do |hub, i|
            write_cell(@sheet, 0, i + 1, hub.name)
          end
          data[:locations].each_with_index do |loc, i|
            name = [loc.zipcode, loc.distance, loc.location&.name].compact.first
            write_cell(@sheet, i + 1, 0, name)
          end
          data[:truckings].each_with_index do |trucking, i|
            t_loc_index = data[:locations].index(trucking.location)
            hub_index = data[:hubs].index(trucking.hub)
            write_cell(@sheet, t_loc_index + 1, hub_index + 1, 'x')
          end
          sheet_index += 1
        end
      end
    end

    def prep_data
      hubs_by_country.each do |country_code, hubs|
        truckings = ::Trucking::Trucking.where(hub: hubs).distinct
        next if truckings.empty?

        tenant_vehicle_ids = truckings.pluck(:tenant_vehicle_id).uniq
        tenant_vehicle_ids.each do |tenant_vehicle_id|
          @hash[country_code][tenant_vehicle_id] = {}
          courier_truckings = truckings.where(tenant_vehicle_id: tenant_vehicle_id)
          next if courier_truckings.empty?

          locations = ::Trucking::Location.where(id: courier_truckings.pluck(:location_id)).distinct
          modifier =  if locations.first.zipcode
            'zipcode'
          elsif locations.first.distance
            'distance'
          else
            'city_name'
          end
          @hash[country_code][tenant_vehicle_id][:locations] = locations.sort_by {|loc| loc[modifier] }
          @hash[country_code][tenant_vehicle_id][:truckings] = courier_truckings
          @hash[country_code][tenant_vehicle_id][:hubs] = hubs
          @hash[country_code][tenant_vehicle_id][:modifier] = modifier
        end
      end
    end

    attr_accessor :purge_ids, :book
  end
end
