# frozen_string_literal: true

module RmsSync
  class LocalCharges < RmsSync::Base

    def initialize(organization_id:, sheet_type: :local_charges, sandbox: nil)
      super
      @book = RmsData::Book.find_or_create_by(organization: @organization, sheet_type: sheet_type)
    end

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

    def local_charges
      ::Legacy::LocalCharge.where(organization_id: @organization.id)
                          .for_dates(Date.today, 2.months.from_now)
    end

    def create_sheet
      @sheet = @book.sheets.create(organization_id: @organization.id, sheet_index: 0)
    end

    def create_data_cells
      row_index = 1
      cells = []
      local_charges.each do |local_charge|
        local_charge.fees.each do |_key, fee|
          if fee['range'].present?
            fee['range'].each do |range|
              default_headers.each_with_index do |head, header_index|
                cells << cell_data(
                    local_charge: local_charge,
                    fee: fee,
                    header: head,
                    row: row_index,
                    index: header_index,
                    sheet: @sheet,
                    range: range
                  )
              end
              row_index += 1
            end
          else
            default_headers.each_with_index do |head, header_index|
              cells << cell_data(
                  local_charge: local_charge,
                  fee: fee,
                  header: head,
                  row: row_index,
                  index: header_index,
                  sheet: @sheet
                )
            end
            row_index += 1
          end
        end
      end
      RmsData::Cell.import(cells)
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
      %w(HUB COUNTRY EFFECTIVE_DATE EXPIRATION_DATE COUNTERPART_HUB COUNTERPART_COUNTRY SERVICE_LEVEL CARRIER FEE_CODE
        FEE MOT LOAD_TYPE DIRECTION CURRENCY RATE_BASIS MINIMUM MAXIMUM BASE TON CBM KG ITEM SHIPMENT BILL CONTAINER
        WM RANGE_MIN	RANGE_MAX	DANGEROUS)
    end

    def valid_rate_headers(fee)
      non_rate_headers | fee['rate_basis'].gsub('PER_','').gsub('_RANGE','').split('_')

    end

    def non_rate_headers
      %w(HUB COUNTRY EFFECTIVE_DATE EXPIRATION_DATE COUNTERPART_HUB COUNTERPART_COUNTRY SERVICE_LEVEL CARRIER FEE_CODE
        FEE MOT LOAD_TYPE DIRECTION CURRENCY RATE_BASIS MINIMUM MAXIMUM BASE RANGE_MIN	RANGE_MAX	DANGEROUS)
    end


    def cell_data(sheet:, local_charge:, header:, row:, index:, fee:, range: {})
      obj = {
        organization_id: @organization.id,
        column: index,
        row: row,
        sheet_id: sheet.id
      }
      valid_cell_headers = valid_rate_headers(fee)
      if valid_cell_headers.include?(header)
        value = case header
                when 'HUB'
                  hub_name(local_charge.hub)
                when 'COUNTRY'
                  local_charge.hub&.address&.country&.name
                when 'COUNTERPART_COUNTRY'
                  local_charge.counterpart_hub&.address&.country&.name
                when 'SERVICE_LEVEL'
                  local_charge.tenant_vehicle&.name
                when 'CARRIER'
                  local_charge.tenant_vehicle&.carrier&.name
                when 'COUNTERPART_HUB'
                  hub_name(local_charge.counterpart_hub)
                when 'FEE_CODE'
                  fee['key']
                when 'FEE'
                  fee['name']
                when 'MOT'
                  local_charge.mode_of_transport
                when 'MINIMUM'
                  fee['min']
                when 'MAXIMUM'
                  fee['max']
                when 'KG'
                  fee['kg'] || (range['rate'] && range['rate_basis'].include?('KG') ? range['rate'] : nil)
                when 'RANGE_MIN'
                  range['min']
                when 'RANGE_MAX'
                  range['max']
                when 'ITEM', 'SHIPMENT', 'BILL', 'CONTAINER', 'WM'
                  fee['value']
                when 'DANGEROUS'
                  local_charge.dangerous.to_s
                else
                  method_name = header.downcase.to_sym
                  if local_charge.respond_to?(method_name)
                    local_charge.send(method_name)
                  elsif fee.has_key?(method_name.to_s)
                    fee.fetch(method_name.to_s)
                  elsif range.has_key?(method_name.to_s)
                    range.fetch(method_name.to_s)
                  end
                end
      end

      obj[:value] = value.present? ? value : nil

      obj
    end
    attr_accessor :purge_ids, :book
  end
end
