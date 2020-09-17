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
        email: 'EMAIL',
        vat_number: 'VAT_NUMBER',
        external_id: 'EXTERNAL_ID',
        address: 'ADDRESS',
        password: 'PASSWORD'
      )
    end

    def client
      @client = Organizations::User.find_by(
        organization_id: @user.organization_id,
        email: @client_row[:email]
      )
    end

    def update_client
      @client.update_attributes(
        organization_id: @user.organization_id,
        email: @client_row[:email]
      )
    end

    def create_client
      Authentication::User.create!(
        type: 'Organizations::User',
        organization_id: @user.organization_id,
        email: @client_row[:email],
        password: @client_row[:password]
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
      update_or_create_client_profile
      @client
    end

    def overwrite_clients
      client_rows
      client_rows.map do |client_row|
        @client_row = client_row
        client
        update_or_create_client
      end
      { stats: stats, results: results }
    end

    def update_or_create_client_profile
      Profiles::ProfileService.create_or_update_profile(user: @client,
                                                        first_name: @client_row[:first_name],
                                                        last_name: @client_row[:last_name],
                                                        company_name: @client_row[:company_name],
                                                        phone: @client_row[:phone])
    end
  end
end
