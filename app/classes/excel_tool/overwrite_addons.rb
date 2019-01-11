# frozen_string_literal: true

module ExcelTool
  class OverwriteAddons < ExcelTool::BaseTool
    attr_reader :user
    def post_initialize(args)
      @user = args[:_user]
    end

    def perform
      overwrite_addons
    end

    private

    def overwrite_addons
      xlsx.sheets.each do |sheet_name|
        first_sheet = xlsx.sheet(sheet_name)
        hub = Hub.find_by(name: sheet_name, tenant_id: user.tenant_id)
        addons = _addons
        customs = _customs
        if hub
          rows = parse_sheet(first_sheet)
          next if rows.empty?
          hash = build_hash(rows, addons, hub)
          counterparts = hash[:counterparts]
          tenant_vehicles = hash[:tenant_vehicles]
          addons = hash[:addons]
          customs = hash[:customs]

          rows.each do |row|
            update_hashes(row, addons, tenant_vehicles, counterparts)
          end
        end

        update_result_and_stats_fees(addons, tenant_vehicles, hub)
      end
      { stats: stats, results: results }
    end

    def local_stats
      {
        charges: {
          number_updated: 0,
          number_created: 0
        },
        customs: {
          number_updated: 0,
          number_created: 0
        }
      }
    end

    def _results
      {
        charges: [],
        customs: []
      }
    end

    def parse_sheet(first_sheet)
      first_sheet.parse(
        fee:             "FEE",
        mot:             "MOT",
        fee_code:        "FEE_CODE",
        carrier:         "CARRIER",
        cargo_class:     "LOAD_TYPE",
        direction:       "DIRECTION",
        currency:        "CURRENCY",
        rate_basis:      "RATE_BASIS",
        ton:             "TON",
        cbm:             "CBM",
        kg:              "KG",
        item:            "ITEM",
        shipment:        "SHIPMENT",
        bill:            "BILL",
        container:       "CONTAINER",
        minimum:         "MINIMUM",
        wm:              "WM",
        effective_date:  "EFFECTIVE_DATE",
        expiration_date: "EXPIRATION_DATE",
        range_min:       "RANGE_MIN",
        range_max:       "RANGE_MAX",
        service_level:   "SERVICE_LEVEL",
        destination:     "DESTINATION",
        title:           "TITLE",
        text_array:      "TEXT_ARRAY",
        read_more:       "READ_MORE",
        accept_text:     "ACCEPT_TEXT",
        decline_text:    "DECLINE_TEXT",
        additional_info: "ADDITIONAL_INFO",
        addon_type:      "ADDON_TYPE"
      )
    end

    def hub_type_name
      {
        "ocean" => "Port",
        "air"   => "Airport",
        "rail"  => "Railyard",
        "truck" => "Depot"
      }
    end

    def _addons
      {
        "general" => {
          "general" => {}
        }
      }
    end

    def _customs
      {
        "general" => {
          "general" => {}
        }
      }
    end

    def find_hub(row)
      hub_name = row[:destination].include?(hub_type_name[row[:mot].downcase]) ? row[:destination] : "#{row[:destination]} #{hub_type_name[row[:mot].downcase]}"
      Hub.find_by(name: hub_name, tenant_id: user.tenant_id)
    end

    def tenant_vehicle_id(row)
      TenantVehicle.find_by(
        tenant_id:         user.tenant_id,
        mode_of_transport: row[:mot].downcase,
        name:              row[:service_level],
        carrier:           Carrier.find_by_name(row[:carrier])
      ).try(:id)
    end

    def create_vehicle_from_name(row, name=nil)
      name ||= row[:service_level]
      Vehicle.create_from_name(name, row[:mot].downcase, user.tenant_id, row[:carrier]).id
    end

    def build_hash(rows, addons, hub)
      counterparts = {}
      tenant_vehicles = {}
      rows.each do |row|
        if row[:destination]
          counterpart_hub = find_hub(row)
          counterpart_hub_id = counterpart_hub.id
          addons[counterpart_hub_id] = {} unless addons[counterpart_hub_id]
          counterparts["#{row[:destination]} #{hub_type_name[row[:mot].downcase]}"] = counterpart_hub_id
        end
        if row[:service_level]
          tenant_vehicles["#{row[:service_level]}-#{row[:mot].downcase}"] = tenant_vehicle_id(row)
          tenant_vehicles["#{row[:service_level]}-#{row[:mot].downcase}"] ||= create_vehicle_from_name(row)
          tenant_vehicle_id = tenant_vehicles["#{row[:service_level]}-#{row[:mot].downcase}"]
        else
          tenant_vehicle_id = "general"
        end

        unless tenant_vehicles["standard-#{row[:mot].downcase}"]
          tenant_vehicles["standard-#{row[:mot].downcase}"] = tenant_vehicle_id(row)
          tenant_vehicles["standard-#{row[:mot].downcase}"] ||= create_vehicle_from_name(row, "standard")
        end
        counterpart_id = counterpart_hub_id || "general"
        addons[counterpart_id][tenant_vehicle_id] = {} unless addons[counterpart_id][tenant_vehicle_id]
        addons[counterpart_id][tenant_vehicle_id][row[:direction].downcase] = {} unless addons[counterpart_id][tenant_vehicle_id][row[:direction].downcase]
        populate_addons_for_cargo_class(addons, row, tenant_vehicle_id, hub, counterpart_id)
      end
      hash_builder = { addons: addons }
      { addons: hash_builder[:addons], tenant_vehicles: tenant_vehicles, counterparts: counterparts }
    end

    def populate_addons_for_cargo_class(addons, row, tv_id, hub, counter_id)
      cargo_classes = if row[:cargo_class].casecmp("fcl").zero?
                        %w(fcl_20 fcl_40 fcl_40_hq)
                      else
                        [row[:cargo_class].downcase]
                      end
      direction = row[:direction].downcase
      cargo_classes.each do |lt|
        addons[counter_id][tv_id][direction][lt] = {} unless addons[counter_id][tv_id][direction][lt]
        addons[counter_id][tv_id][direction][lt][row[:addon_type]] = addons_and_customs_builder(
          hub, lt, tv_id, counter_id, row
        )
      end
      { addons: addons }
    end

    def addons_and_customs_builder(hub, lt, tv_id, hub_key, row)
      {
        "fees"                 => {},
        "direction"            => row[:direction].downcase,
        "mode_of_transport"    => row[:mot].downcase,
        "tenant_id"            => hub.tenant_id,
        "hub_id"               => hub.id,
        "cargo_class"          => lt,
        "tenant_vehicle_id"    => tv_id != "general" ? tv_id : nil,
        "counterpart_hub_id"   => hub_key != "general" ? hub_key : nil,
        "addon_type"           => row[:addon_type].downcase,
        "title"                => row[:title],
        "text"                 => text_object_from_csv(row[:text_array]),
        "read_more"            => row[:read_more],
        "additional_info_text" => row[:additional_info],
        "addon_type"           => row[:addon_type]

      }
    end

    def build_charge(row)
      case row[:rate_basis].upcase
      when "PER_SHIPMENT"
        charge = { currency: row[:currency], value: row[:shipment], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_CONTAINER"
        charge = { currency: row[:currency], value: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_BILL"
        charge = { currency: row[:currency], min: row[:minimum], value: row[:bill], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_CBM"
        charge = { currency: row[:currency], min: row[:minimum], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_KG"
        charge = { currency: row[:currency], min: row[:minimum], value: row[:kg], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_TON"
        charge = { currency: row[:currency], ton: row[:ton], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_WM"
        charge = { currency: row[:currency], value: row[:wm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_ITEM"
        charge = { currency: row[:currency], value: row[:item], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_CBM_TON"
        charge = { currency: row[:currency], cbm: row[:cbm], ton: row[:ton], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_SHIPMENT_CONTAINER"
        charge = { currency: row[:currency], shipment: row[:shipment], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_BILL_CONTAINER"
        charge = { currency: row[:currency], bill: row[:bill], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_CBM_KG"
        charge = { currency: row[:currency], cbm: row[:cbm], kg: row[:kg], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee] }
      when "PER_KG_RANGE"
        charge = { currency: row[:currency], kg: row[:kg], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], range_min: row[:range_min], range_max: row[:range_max] }
      when "UNKNOWN"
        charge = { currency: row[:currency], kg: row[:kg], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], unknown: true }
      end

      charge[:expiration_date] = row[:expiration_date]
      charge[:effective_date] = row[:effective_date]
      charge
    end

    def update_hashes(row, addons, tenant_vehicles, counterparts)
      charge = build_charge(row)
      addons = addon_load_setter(
        addons,
        charge,
        row[:cargo_class].downcase,
        row[:direction].downcase,
        tenant_vehicles["#{row[:service_level]}-#{row[:mot].downcase}"] || "general",
        row[:mot],
        counterparts["#{row[:destination]} #{hub_type_name[row[:mot].downcase]}"] || "general",
        row[:addon_type]
      )
    end

    def attach_text(row, addons, tenant_vehicles, counterparts)
      tv_id =  tenant_vehicles["#{row[:service_level]}-#{row[:mot].downcase}"] || "general"
      cph_id = counterparts["#{row[:destination]} #{hub_type_name[row[:mot].downcase]}"] || "general"
      dir = row[:direction].downcase
      lt = row[:cargo_class].downcase
      add_on = addons[tv_id][dir][lt]
      v["title"] = row[:title]
      v["text"] = text_object_from_csv(row[:text_array])
      v["read_more"] = row[:read_more]
      v["additional_info_text"] = row[:additional_info]
      v["addon_type"] = row[:addon_type]
    end

    def text_object_from_csv(str)
      if str.is_a? Array
        str.map { |s| { text: s } }
      elsif str.is_a?(String) && str.include?('\", \"')
        str.map { |s| { text: s.chomp } }
      elsif str.is_a?(String)
        [{ text: str }]
      end
    end

    def update_result_and_stats_fees(addons, tenant_vehicles, hub)
      addons.each do |_hub_key, tv_ids|
        tv_ids.each do |_tv_id, directions|
          directions.each do |direction_key, load_type_values|
            load_type_values.each do |lt, type_object|
              type_object.each do |type, obj|
                obj["tenant_vehicle_id"] ||= tenant_vehicles["standard-#{obj['mode_of_transport']}"]

                lc = hub.addons.find_by(mode_of_transport: obj["mode_of_transport"], cargo_class: lt,
                  direction: direction_key, tenant_vehicle_id: obj["tenant_vehicle_id"],
                  counterpart_hub_id: obj["counterpart_hub_id"], addon_type: type)
                if lc
                  lc.update_attributes(obj)
                else

                  hub.addons.create!(obj)
                end
                results[:charges] << obj
                stats[:charges][:number_updated] += 1
              end
            end
          end
        end
      end
    end

    def rate_value(charge)
      case charge[:rate_basis]
      when "PER_KG_RANGE"
        charge[:kg]
      end
    end

    def pushable_charg(charge)
      {
        currency:   charge[:currency],
        rate_basis: charge[:rate_basis],
        min:        charge[:range_min],
        max:        charge[:range_max],
        rate:       rate_value(charge)
      }
    end

    def expanded_charge(charge)
      {
        effective_date:  charge[:effective_date],
        expiration_date: charge[:expiration_date],
        currency:        charge[:currency],
        rate_basis:      charge[:rate_basis],
        min:             charge[:min],
        range:           [
          {
            currency: charge[:currency],
            min:      charge[:range_min],
            max:      charge[:range_max],
            rate:     rate_value(charge)
          }
        ],
        key:             charge[:key],
        name:            charge[:name]
      }
    end

    def set_range_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, _mot, counterpart_hub_id)
      existing_charge = all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]["fees"][charge[:key]]
      if existing_charge && existing_charge[:range]
        all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]["fees"][charge[:key]][:range] << pushable_charg(charge)
      else
        all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]["fees"][charge[:key]] = expanded_charge(charge)
      end
      all_charges
    end

    def addon_load_setter(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id, type)
      debug_message(charge)
      debug_message(all_charges)

      if counterpart_hub_id == "general" && tenant_vehicle_id != "general"
        all_charges.keys.each do |ac_key|
          if all_charges[ac_key][tenant_vehicle_id]
            set_general_addon(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, ac_key, type)
          end
        end

      elsif counterpart_hub_id == "general" && tenant_vehicle_id == "general"
        all_charges.keys.each do |ac_key|
          all_charges[ac_key].keys.each do |tv_key|
            if all_charges[ac_key][tv_key]
              set_general_addon(all_charges, charge, load_type, direction, tv_key, mot, ac_key, type)
            end
          end
        end

      else
        if all_charges[counterpart_hub_id][tenant_vehicle_id]
          set_general_addon(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id, type)
        end
      end
      all_charges
    end

    def set_general_addon(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id, type)
      if charge[:rate_basis].include? "RANGE"
        if load_type === "fcl"
          %w(fcl_20 fcl_40 fcl_40_hq).each do |lt|
            set_range_fee(all_charges, charge, lt, direction, tenant_vehicle_id, mot, counterpart_hub_id, type)
          end
        else
          set_range_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id, type)
        end
      else
        set_regular_addon(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id, type)
      end
    end

    def set_regular_addon(all_charges, charge, load_type, direction, tenant_vehicle_id, _mot, counterpart_hub_id, type)
      if load_type === "fcl"
        %w(fcl_20 fcl_40 fcl_40_hq).each do |lt|
          all_charges[counterpart_hub_id][tenant_vehicle_id][direction][lt][type]["fees"][charge[:key]] = charge
        end
      else
        if !all_charges[counterpart_hub_id] ||
           !all_charges[counterpart_hub_id][tenant_vehicle_id] ||
           !all_charges[counterpart_hub_id][tenant_vehicle_id][direction] ||
           !all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type] ||
           !all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type][type]

        end
        all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type][type]["fees"][charge[:key]] = charge
      end
      all_charges
    end
  end
end
