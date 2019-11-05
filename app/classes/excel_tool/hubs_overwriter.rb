# frozen_string_literal: true

module ExcelTool
  class HubsOverwriter < ExcelTool::BaseTool
    attr_reader :first_sheet, :country, :nexus, :user, :hub_row, :address, :mandatory_charge

    def post_initialize(args)
      @first_sheet = xlsx.sheet(xlsx.sheets.first)
      @user = args[:_user]
      @sandbox = args.fetch(:sandbox)
    end

    def perform
      overwrite_hubs
      stats
    end

    private

    def _stats
      {
        hubs: {
          number_updated: 0,
          number_created: 0
        },
        nexuses: {
          number_updated: 0,
          number_created: 0
        }
      }
    end

    def _results
      {
        hubs: [],
        nexuses: []
      }
    end

    def hub_rows
      @hub_rows ||= first_sheet.parse(
        hub_status: 'STATUS',
        hub_type: 'TYPE',
        hub_name: 'NAME',
        locode: 'LOCODE',
        latitude: 'LATITUDE',
        longitude: 'LONGITUDE',
        country: 'COUNTRY',
        geocoded_address: 'FULL_ADDRESS',
        photo: 'PHOTO',
        free_out: 'FREE_OUT',
        import_charges: 'IMPORT_CHARGES',
        export_charges: 'EXPORT_CHARGES',
        pre_carriage: 'PRE_CARRIAGE',
        on_carriage: 'ON_CARRIAGE',
        alternative_names: 'ALTERNATIVE_NAMES'
      )
    end

    def hub_type_name
      @hub_type_name ||= {
        'ocean' => 'Port',
        'air' => 'Airport',
        'rail' => 'Railyard',
        'truck' => 'Depot'
      }
    end

    def default_mandatory_charge
      @default_mandatory_charge ||= MandatoryCharge.falsified
    end

    def mandatory_charge_values
      {
        pre_carriage: hub_row[:pre_carriage] || false,
        on_carriage: hub_row[:on_carriage] || false,
        import_charges: hub_row[:import_charges] || false,
        export_charges: hub_row[:export_charges] || false
      }
    end

    def _nexus
      Nexus.find_by(
        name: hub_row[:hub_name],
        country: country,
        tenant_id: @user.tenant_id,
        sandbox: @sandbox
      )
    end

    def nexus_create
      Nexus.create!(
        name: hub_row[:hub_name],
        latitude: hub_row[:latitude],
        longitude: hub_row[:longitude],
        photo: hub_row[:photo],
        locode: hub_row[:locode],
        country: country,
        tenant_id: @user.tenant_id,
        sandbox: @sandbox
      )
    end

    def nexus_update
      @nexus.update!(
        latitude: hub_row[:latitude],
        longitude: hub_row[:longitude],
        photo: hub_row[:photo],
        locode: hub_row[:locode]
      )
    end

    def find_or_create_address
      address_string = hub_row[:geocoded_address] || [hub_row[:hub_name], country&.name].join(', ')
      Address.find_or_create_by(
        name: hub_row[:hub_name],
        latitude: hub_row[:latitude],
        longitude: hub_row[:longitude],
        country: country,
        city: hub_row[:hub_name],
        geocoded_address: address_string,
        sandbox: @sandbox
      )
    end

    def find_alternative_country_names(name)
      results = AlternativeName.where('model = ? AND name ILIKE ?', 'Country', "%#{name}%")
      unless results.empty?
        class_name = results.first.model.constantize
        country = class_name.find(results.first.model_id)
      end
    end

    def hub
      @hub = Hub.find_by(
        nexus_id: nexus.id,
        tenant_id: user.tenant_id,
        hub_type: hub_row[:hub_type],
        name: "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}",
        sandbox: @sandbox
      )
    end

    def update_hub
      @hub.update_attributes(
        nexus_id: nexus.id,
        address_id: address.id,
        tenant_id: user.tenant_id,
        hub_type: hub_row[:hub_type],
        trucking_type: hub_row[:trucking_type],
        latitude: hub_row[:latitude] || address.latitude,
        longitude: hub_row[:longitude] || address.longitude,
        name: "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}",
        photo: hub_row[:photo],
        mandatory_charge: @mandatory_charge,
        hub_code: hub_row[:locode],
        free_out: hub_row[:pre_carriage] || false
      )
    end

    def create_alternative_names
      if hub_row[:alternative_names]
        if hub_row[:alternative_names].include?(',')
          hub_row[:alternative_names].split(',').each do |str|
            AlternativeName.find_or_create_by!(model: 'Hub', model_id: @hub.id, name: str)
          end
        else
          AlternativeName.find_or_create_by!(model: 'Hub', model_id: @hub.id, name: hub_row[:alternative_names])
        end
      end
    end

    def create_nexus_hub
      nexus.hubs.create!(
        nexus_id: nexus.id,
        address_id: address.id,
        tenant_id: user.tenant_id,
        hub_type: hub_row[:hub_type],
        trucking_type: hub_row[:trucking_type],
        latitude: hub_row[:latitude] || address.latitude,
        longitude: hub_row[:longitude] || address.longitude,
        name: "#{nexus.name} #{hub_type_name[hub_row[:hub_type]]}",
        photo: hub_row[:photo],
        mandatory_charge: @mandatory_charge,
        sandbox: @sandbox,
        hub_code: hub_row[:locode]
      )
    end

    def update_or_create_hub
      if hub
        update_hub
        results[:hubs] << hub
        stats[:hubs][:number_updated] += 1
      else
        @hub = create_nexus_hub
        results[:hubs] << hub
        stats[:hubs][:number_created] += 1
      end
    end

    def update_address_geocode
      unless address.street_number
        address.reverse_geocode
        address.save!
      end

      unless address.latitude.present? && address.longitude.present?
        address.geocode
        address.save!
      end
    end

    def geoplace
      return @geoplace if @geoplace

      country_names = hub_rows.map { |hub| hub[:country] }
      @geoplace = Country.geo_find_by_names(country_names)
    end

    def country_by_code(name)
      name = 'Korea (Republic of)' if name.include?('Korea')
      tmp_country = Country.find_by_name(name)
      unless tmp_country
        code = geoplace.select { |geo| geo.name == name }&.first&.code
        tmp_country = Country.find_by(code: code)
      end
      tmp_country ||= Country.where('name ILIKE ?', "%#{name}%").first
      tmp_country ||= find_alternative_country_names(name)
      tmp_country
    end

    def overwrite_hubs
      hub_rows.map do |_hub_row|
        @hub_row = _hub_row
        hub_row[:hub_type] = hub_row[:hub_type].downcase
        @country = country_by_code(hub_row[:country])
        @mandatory_charge = MandatoryCharge.find_by(mandatory_charge_values)
        @mandatory_charge ||= default_mandatory_charge

        @nexus = _nexus
        if @nexus
          nexus_update
        else
          @nexus = nexus_create
        end
        @address = find_or_create_address
        update_address_geocode
        update_or_create_hub
        results[:nexuses] << nexus
        stats[:nexuses][:number_updated] += 1
        create_alternative_names
        hub
      end
    end
  end
end
