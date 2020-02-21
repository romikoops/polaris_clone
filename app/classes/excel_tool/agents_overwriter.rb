# frozen_string_literal: true

module ExcelTool
  class AgentsOverwriter < ExcelTool::BaseTool
    attr_reader :first_sheet, :user, :agent_row

    def post_initialize(args)
      @user = args[:user]
      @manager_role = Role.find_by_name('agency_manager')
      @agent_role = Role.find_by_name('agent')
      @stats = {
        agents: {
          number_updated: 0,
          number_created: 0
        },
        agencies: {
          number_updated: 0,
          number_created: 0
        },
        agency_managers: {
          number_updated: 0,
          number_created: 0
        }
      }
    end

    def perform
      overwrite_agents
    end

    private

    def _results
      {
        agents: [],
        agencies: [],
        agency_managers: []
      }
    end

    def agent_rows
      @agent_rows ||= xlsx.sheet('Agents').parse(
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

    def agency_rows
      @agency_rows ||= xlsx.sheet('Agencies').parse(
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

    def agency
      @agency = Agency.find_by(
        name: @agency_row[:company_name],
        tenant_id: @user.tenant_id
      )
    end

    def update_agency
      @agency.update_attributes(
        name:  @agency_row[:company_name]
      )
    end

    def create_agency
      @user.tenant.agencies.create!(
        name:  @agency_row[:company_name]
      )
    end

    def update_or_create_agency
      if @agency
        update_agency
        results[:agencies] << @agency
        @stats[:agencies][:number_updated] += 1
      else
        @agency = create_agency
        results[:agencies] << @agency
        @stats[:agencies][:number_created] += 1
      end
    end

    def agency_manager
      @agency_manager = User.find_by(
        tenant_id: @user.tenant_id,
        email: @agency_row[:email].downcase,
        role: @manager_role
      )
    end

    def update_agency_manager
      @agency_manager.update_attributes(
        tenant_id: @user.tenant_id,
        email: @agency_row[:email].downcase,
        vat_number: @agency_row[:vat_number],
        external_id: @agency_row[:external_id],
        agency_id: @agency.id,
        role: @manager_role
      )
    end

    def create_agency_manager
      @user.tenant.users.create!(
        tenant_id: @user.tenant_id,
        email: @agency_row[:email].downcase,
        vat_number: @agency_row[:vat_number],
        external_id: @agency_row[:external_id],
        agency_id: @agency.id,
        role: @manager_role
      )
    end

    def update_agency_with_manager
      @agency.agency_manager_id = @agency_manager.id
      @agency.save!
    end

    def update_or_create_agency_manager
      if @agency_manager
        update_agency_manager
        update_agency_with_manager
        results[:agency_managers] << @agency_manager
        @stats[:agency_managers][:number_updated] += 1
      else
        @agency_manager = create_agency_manager
        update_agency_with_manager
        results[:agency_managers] << @agency_manager
        @stats[:agency_managers][:number_created] += 1
      end
      update_or_create_user_profile(row: @agency_row, target: @agency_manager)
    end

    def agent
      @agent = User.find_by(
        tenant_id: @user.tenant_id,
        email: @agent_row[:email].downcase,
        agency_id: @agent_agency.id,
        role: @agent_role
      )
    end

    def update_agent
      @agent.update_attributes(
        tenant_id: @user.tenant_id,
        email: @agent_row[:email].downcase,
        vat_number: @agent_row[:vat_number],
        agency_id: @agent_agency.id,
        role: @agent_role
      )
    end

    def create_agent
      @user.tenant.users.create!(
        tenant_id: @user.tenant_id,
        email: @agent_row[:email].downcase,
        vat_number: @agent_row[:vat_number],
        password: @agent_row[:password],
        agency_id: @agent_agency.id,
        role: @agent_role
      )
    end

    def update_or_create_agent
      if @agent
        update_agent
        results[:agents] << @agent
        stats[:agents][:number_updated] += 1
      else
        @agent = create_agent
        results[:agents] << @agent
        stats[:agents][:number_created] += 1
      end
      update_or_create_user_profile(row: @agent_row, target: @agent)
    end

    def determine_agent_agency
      @agent_agency = @user.tenant.agencies.find_by(name: @agent_row[:company_name])
    end

    def overwrite_agents
      agent_rows
      agency_rows
      agency_rows.map do |raw_agency_row|
        @agency_row = raw_agency_row
        agency
        update_or_create_agency
        agency_manager
        update_or_create_agency_manager
      end
      agent_rows.map do |raw_agent_row|
        @agent_row = raw_agent_row
        determine_agent_agency
        agent
        update_or_create_agent
      end
      @stats
    end

    def update_or_create_user_profile(row:, target:)
      tenants_user = Tenants::User.find_by(legacy_id: target.id)
      Profiles::ProfileService.create_or_update_profile(user: tenants_user,
                                                        first_name: row[:first_name],
                                                        last_name: row[:last_name],
                                                        phone: row[:phone])
      target
    end
  end
end
