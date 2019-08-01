# frozen_string_literal: true

module RmsSync
  class Hubs < RmsSync::Base
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

    def hubs
      ::Legacy::Hub.where(tenant_id: @tenant.legacy_id, sandbox: @sandbox)
    end

    def create_sheet
      @sheet = @book.sheets.create(tenant_id: @tenant.id, sheet_index: 0)
    end

    def create_data_cells
      hubs.each_with_index do |hub, hub_index|
        default_headers.each_with_index do |head, header_index|
          @sheet.cells.create!(hub_data(hub: hub, header: head, row: hub_index + 1, index: header_index))
        end
      end
    end

    def create_header_row
      default_headers.each_with_index do |head, i|
        @sheet.cells.create!(
          tenant_id: @tenant.id,
          row: 0,
          column: i,
          value: head
        )
      end
    end

    def default_headers
      %w(STATUS	TYPE	NAME	CODE	LATITUDE	LONGITUDE	COUNTRY	FULL_ADDRESS
        PHOTO	IMPORT_CHARGES	EXPORT_CHARGES	PRE_CARRIAGE	ON_CARRIAGE	ALTERNATIVE_NAMES)
    end

    def hub_data(hub:, header:, row:, index:)
      obj = {
        tenant_id: @tenant.id,
        column: index,
        row: row
      }
      mandatory_charge = hub.mandatory_charge
      value = case header
              when 'STATUS'
                hub.hub_status
              when 'TYPE'
                hub.hub_type
              when 'NAME'
                hub_name(hub)
              when 'CODE'
                hub.hub_code
              when 'LATITUDE'
                hub.latitude || hub.address&.latitude
              when 'LONGITUDE'
                hub.longitude || hub.address&.longitude
              when 'COUNTRY'
                hub.address&.country&.name
              when 'FULL_ADDRESS'
                hub.address&.geocoded_address
              when 'PHOTO'
                hub.photo
              when 'IMPORT_CHARGES'
                mandatory_charge&.import_charges
              when 'EXPORT_CHARGES'
                mandatory_charge&.export_charges
              when 'PRE_CARRIAGE'
                mandatory_charge&.pre_carriage
              when 'ON_CARRIAGE'
                mandatory_charge&.on_carriage
              else
                ''
              end

      obj[:value] = value.present? ? value : nil

      obj
    end
    attr_accessor :purge_ids, :book
  end
end
