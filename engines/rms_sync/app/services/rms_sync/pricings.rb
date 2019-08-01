# frozen_string_literal: true

module RmsSync
  class Pricings < RmsSync::Base
    def perform
      prepare_purge
      sync_data
      purge
    end

    def sync_data
      create_sheet
      create_header_row
      create_data_cells
    end

    def pricings
      ::Pricings::Pricing.where(tenant_id: @tenant.legacy_id, sandbox: @sandbox)
                          .for_dates(Date.today - 1, Date.today + 2.months)
    end

    def create_sheet
      @sheet = @book.sheets.create(tenant_id: @tenant.id, sheet_index: 0)
    end

    def create_data_cells
      row_index = 1
      pricings.each do |pricing|
        pricing.fees.each do |fee|
          if fee.range.present?
            fee.range.each do |range|
              default_headers.each_with_index do |head, header_index|
                @sheet.cells.create!(
                  pricing_data(fee: fee, header: head, row: row_index, index: header_index, range: range)
                )
              end
              row_index += 1
            end
          else
            default_headers.each_with_index do |head, header_index|
              @sheet.cells.create!(
                pricing_data(fee: fee, header: head, row: row_index, index: header_index)
              )
            end
            row_index += 1
          end
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
      %w(EFFECTIVE_DATE	EXPIRATION_DATE	ORIGIN	COUNTRY_ORIGIN	DESTINATION	COUNTRY_DESTINATION	MOT	
        CARRIER	SERVICE_LEVEL	LOAD_TYPE	RATE_BASIS	RANGE_MIN	RANGE_MAX	FEE_CODE	FEE_NAME	CURRENCY	FEE_MIN	FEE)
    end

    def pricing_data(fee:, header:, row:, index:, range: {})
      obj = {
        tenant_id: @tenant.id,
        column: index,
        row: row
      }

      value = case header
              when 'EFFECTIVE_DATE'
                fee.pricing.effective_date
              when 'EXPIRATION_DATE'
                fee.pricing.expiration_date
              when 'ORIGIN'
                hub_name(fee.pricing.itinerary&.first_stop&.hub)
              when 'COUNTRY_ORIGIN'
                fee.pricing.itinerary&.first_stop&.hub&.address&.country&.name
              when 'DESTINATION'
                hub_name(fee.pricing.itinerary&.last_stop&.hub)
              when 'COUNTRY_DESTINATION'
                fee.pricing.itinerary&.last_stop&.hub&.address&.country&.name
              when 'MOT'
                fee.pricing.itinerary&.mode_of_transport
              when 'CARRIER'
                fee.pricing.tenant_vehicle&.carrier&.name
              when 'SERVICE_LEVEL'
                fee.pricing.tenant_vehicle&.name
              when 'LOAD_TYPE'
                fee.pricing.cargo_class
              when 'RATE_BASIS'
                fee.rate_basis&.external_code
              when 'RANGE_MIN'
                range['min']
              when 'RANGE_MAX'
                range['max']
              when 'FEE_CODE'
                fee.fee_code
              when 'FEE_NAME'
                fee.fee_name
              when 'CURRENCY'
                fee.currency_name
              when 'FEE_MIN'
                fee.min
              when 'FEE'
                range.present? ? range['rate'] : fee.rate
              end

      obj[:value] = value.present? ? value : nil

      obj
    end
    attr_accessor :purge_ids, :book
  end
end
