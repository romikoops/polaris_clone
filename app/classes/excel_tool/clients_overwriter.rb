# frozen_string_literal: true

module ExcelTool
  class ClientsOverwriter < ExcelTool::BaseTool
    attr_reader :first_sheet, :user, :client_row

    def post_initialize(args)
      @first_sheet = xlsx.sheet(xlsx.sheets.first)
      @user = args[:_user]
    end

    def perform
      overwrite_clients
    end

    private

    def _stats
      {
        type: 'clients',
        clients: {
          number_updated: 0,
          number_created: 0
        }
      }
    end

    def _results
      {
        clients: []
      }
    end

    def client_rows
      @client_rows ||= first_sheet.parse(
        first_name: 'FIRST_NAME',
        last_name: 'LAST_NAME',
        email: 'EMAIL',
        phone: 'PHONE',
        company_name: 'COMPANY_NAME',
        vat_number: 'VAT_NUMBER',
        external_id: 'EXTERNAL_ID',
        address: 'ADDRESS',
        password: 'PASSWORD'
      )
    end

    def client
      @client = User.find_by(
        first_name: @client_row[:first_name],
        last_name: @client_row[:last_name],
        tenant_id: @user.tenant_id,
        email: @client_row[:email],
        company_name: @client_row[:company_name],
        phone: @client_row[:phone],
        vat_number: @client_row[:vat_number],
        external_id: @client_row[:external_id]
      )
    end

    def update_client
      @client.update_attributes(
        first_name: @client_row[:first_name],
        last_name: @client_row[:last_name],
        tenant_id: @user.tenant_id,
        email: @client_row[:email],
        company_name: @client_row[:company_name],
        phone: @client_row[:phone],
        vat_number: @client_row[:vat_number],
        external_id: @client_row[:external_id]
      )
    end

    def create_client
      @user.tenant.users.create!(
        first_name: @client_row[:first_name],
        last_name: @client_row[:last_name],
        tenant_id: @user.tenant_id,
        email: @client_row[:email],
        company_name: @client_row[:company_name],
        phone: @client_row[:phone],
        vat_number: @client_row[:vat_number],
        password: @client_row[:password],
        external_id: @client_row[:external_id]
      )
    end

    def update_or_create_client
      if @client
        update_client
        results[:clients] << @client
        stats[:clients][:number_updated] += 1
      else
        @client = create_client
        results[:clients] << @client
        stats[:clients][:number_created] += 1
      end
    end

    def overwrite_clients
      client_rows
      @client_rows.map do |_client_row|
        @client_row = _client_row
        client
        update_or_create_client
      end
      { stats: stats, results: results }
    end
  end
end
