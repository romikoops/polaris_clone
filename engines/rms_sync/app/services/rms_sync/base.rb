# frozen_string_literal: true

module RmsSync
  class Base
    def initialize(tenant_id:, sheet_type:, sandbox: nil)
      @tenant = Tenants::Tenant.find_by(id: tenant_id)
      @sandbox = sandbox
      @sheet_type = sheet_type
      @cells = []
    end

    def prepare_purge
      @purge_ids = if @sheet_type == :trucking
                     RmsData::Book.where(tenant: @tenant, sheet_type: @sheet_type).map { |b| b.sheets.ids }.flatten
                   else
                     @book.sheets.ids
                   end
    end

    def purge
      RmsData::Sheet.where(id: @purge_ids).destroy_all
    end

    def hub_name(hub)
      return '' unless hub

      hub.name.gsub(/ (Port|Airport|Railyard|Depot)/, '')
    end

    def write_cell(sheet, row, col, val)
      @cells << {
        sheet_id: sheet.id,
        tenant_id: @tenant.id,
        row: row,
        column: col,
        value: val
      }
    end
  end
  attr_accessor :tenant, :sheet_type, :book
end
