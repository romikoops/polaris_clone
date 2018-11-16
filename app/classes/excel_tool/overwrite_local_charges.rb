# frozen_string_literal: true

module ExcelTool
  class OverwriteLocalCharges < ExcelTool::BaseTool
    attr_reader :user, :dangerous
    def post_initialize(args)
      @user = args[:user]
      @dangerous = {}
    end

    def perform
      overwrite_local_charges
    end

    private

    def overwrite_local_charges
      xlsx.sheets.each do |sheet_name|
        first_sheet = xlsx.sheet(sheet_name)
        hub = Hub.find_by(name: sheet_name, tenant_id: user.tenant_id)
        hub_fees = _hub_fees
        customs = _customs
        if hub
          rows = parse_sheet(first_sheet)
          next if rows.empty?
          sanitize_rows(rows)
          hash = build_hash(rows, hub_fees, customs, hub)
          counterparts = hash[:counterparts]
          tenant_vehicles = hash[:tenant_vehicles]
          hub_fees = hash[:hub_fees]
          customs = hash[:customs]

          rows.each do |row|
            update_hashes(row, hub_fees, customs, tenant_vehicles, counterparts)
          end
        end
        save_dangerous_fees(hub_fees, tenant_vehicles, hub)
        binding.pry
        update_result_and_stats_fees(hub_fees, tenant_vehicles, hub)
        update_result_and_stats_customs(customs, tenant_vehicles, hub)
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
        fee:             'FEE',
        mot:             'MOT',
        fee_code:        'FEE_CODE',
        load_type:       'LOAD_TYPE',
        direction:       'DIRECTION',
        currency:        'CURRENCY',
        rate_basis:      'RATE_BASIS',
        ton:             'TON',
        cbm:             'CBM',
        kg:              'KG',
        item:            'ITEM',
        shipment:        'SHIPMENT',
        bill:            'BILL',
        container:       'CONTAINER',
        minimum:         'MINIMUM',
        maximum:         'MAXIMUM',
        wm:              'WM',
        effective_date:  'EFFECTIVE_DATE',
        expiration_date: 'EXPIRATION_DATE',
        range_min:       'RANGE_MIN',
        range_max:       'RANGE_MAX',
        service_level:   'SERVICE_LEVEL',
        destination:     'DESTINATION',
        base:            'BASE',
        dangerous:       'DANGEROUS',
        carrier:         'CARRIER'
      )
    end

    def hub_type_name
      {
        'ocean' => 'Port',
        'air' => 'Airport',
        'rail' => 'Railyard',
        'truck' => 'Depot'
      }
    end

    def _hub_fees
      {
        'general' => {
          'general' => {}
        }
      }
    end

    def _customs
      {
        'general' => {
          'general' => {}
        }
      }
    end

    def find_hub(row)
      hub_name = row[:destination].ends_with?(" #{hub_type_name[row[:mot].downcase]}") ? row[:destination] : "#{row[:destination]} #{hub_type_name[row[:mot].downcase]}"
      Hub.find_by(name: hub_name, tenant_id: user.tenant_id)
    end

    def tenant_vehicle_id(row)
      if row[:carrier]
        carrier = Carrier.find_or_create_by!(name: row[:carrier])
        carrier.get_tenant_vehicle(user.tenant_id, row[:mot].downcase, row[:service_level]).try(:id)
      else
        TenantVehicle.find_by(
          tenant_id:         user.tenant_id,
          mode_of_transport: row[:mot].downcase,
          name:              row[:service_level]
        ).try(:id)
      end
    end

    def create_vehicle_from_name(row, name = nil)
      name ||= row[:service_level]
      Vehicle.create_from_name(name, row[:mot].downcase, user.tenant_id, row[:carrier]).id
    end

    def sanitize_rows(rows)
      rows.each do |row|
        row[:load_type].strip!
      end
    end

    def build_hash(rows, hub_fees, customs, hub)
      counterparts = {}
      tenant_vehicles = {}
      rows.each do |row|
        if row[:destination]
          counterpart_hub = find_hub(row)
          puts row unless counterpart_hub
          counterpart_hub_id = counterpart_hub.id
          hub_fees[counterpart_hub_id] = {} unless hub_fees[counterpart_hub_id]
          customs[counterpart_hub_id] = {}  unless customs[counterpart_hub_id]
          counterparts["#{row[:destination]} #{hub_type_name[row[:mot].downcase]}"] = counterpart_hub_id
        end
        if row[:service_level]
          tenant_vehicles["#{row[:carrier]}-#{row[:service_level]}-#{row[:mot].downcase}"] = tenant_vehicle_id(row)
          tenant_vehicles["#{row[:carrier]}-#{row[:service_level]}-#{row[:mot].downcase}"] ||= create_vehicle_from_name(row)
          tenant_vehicle_id = tenant_vehicles["#{row[:carrier]}-#{row[:service_level]}-#{row[:mot].downcase}"]
        else
          tenant_vehicle_id = 'general'
        end

        unless tenant_vehicles["standard-#{row[:mot].downcase}"]
          tenant_vehicles["standard-#{row[:mot].downcase}"] = tenant_vehicle_id(row)
          tenant_vehicles["standard-#{row[:mot].downcase}"] ||= create_vehicle_from_name(row, 'standard')
        end
        counterpart_id = counterpart_hub_id || 'general'

        hub_fees[counterpart_id][tenant_vehicle_id] = {}
        customs[counterpart_id][tenant_vehicle_id] = {}
        store_dangerous_fees(row, counterpart_id, tenant_vehicle_id) if row[:dangerous]
      end

      hash_builder = expand_customs_hub_fees(hub_fees, customs, rows, hub)
      { hub_fees: hash_builder[:hub_fees], customs: hash_builder[:customs], tenant_vehicles: tenant_vehicles, counterparts: counterparts }
    end

    def store_dangerous_fees(row, counterpart_id, tenant_vehicle_id)
      @dangerous[counterpart_id] = {} unless @dangerous[counterpart_id]
      @dangerous[counterpart_id][tenant_vehicle_id] = {} unless @dangerous[counterpart_id][tenant_vehicle_id]
      load_types = if row[:load_type].casecmp('fcl').zero?
                     %w(fcl_20 fcl_40 fcl_40_hq)
                   else
                     [row[:load_type].downcase]
                   end
      charge = build_charge(row)
      load_types.each do |lt|
        @dangerous[counterpart_id][tenant_vehicle_id][row[:direction].downcase] = {} unless @dangerous[counterpart_id][tenant_vehicle_id][row[:direction].downcase]
        @dangerous[counterpart_id][tenant_vehicle_id][row[:direction].downcase][lt] = {} unless @dangerous[counterpart_id][tenant_vehicle_id][row[:direction].downcase][lt]
        @dangerous[counterpart_id][tenant_vehicle_id][row[:direction].downcase][lt][charge[:key]] = charge
      end
    end

    def save_dangerous_fees(hub_fees, tenant_vehicles, hub)
      hub_fees.each do |hub_key, tv_ids|
        tv_ids.each do |tv_id, directions|
          directions.each do |direction_key, load_type_values|
            load_type_values.each do |lt, obj|
              next unless @dangerous[hub_key]
              next unless @dangerous[hub_key][tv_id]
              next unless @dangerous[hub_key][tv_id][direction_key]
              next unless @dangerous[hub_key][tv_id][direction_key][lt]
              dangerous_fees = @dangerous[hub_key][tv_id][direction_key][lt]

              next unless dangerous_fees
              dangerous_fees.each do |key, fee|
                obj['fees'][key] = fee
              end
              obj['dangerous'] = true
              obj['tenant_vehicle_id'] ||= tenant_vehicles["standard-#{obj['mode_of_transport']}"]

              lc = hub.local_charges.find_by(mode_of_transport: obj['mode_of_transport'], load_type: lt,
                                             direction: direction_key, tenant_vehicle_id: obj['tenant_vehicle_id'],
                                             counterpart_hub_id: obj['counterpart_hub_id'], dangerous: true)
              if lc
                lc.update_attributes(obj)
              else
                hub.local_charges.create!(obj)
              end
              results[:charges] << obj
              stats[:charges][:number_updated] += 1
            end
          end
        end
      end
    end

    def expand_customs_hub_fees(hub_fees, customs, rows, hub)
      hub_fees.each do |hub_key, tv_ids|
        tv_ids.keys.each do |tv_id|
          %w(export import).each do |direction|
            hub_fees[hub_key][tv_id][direction] = {} unless hub_fees[hub_key][tv_id][direction]
            customs[hub_key][tv_id][direction] = {} unless customs[hub_key][tv_id][direction]
            %w(lcl fcl_20 fcl_40 fcl_40_hq).each do |lt|
              hub_fees[hub_key][tv_id][direction][lt] = hub_fees_and_customs_builder(direction,
                                                                                     rows[0][:mot].downcase, hub, lt, tv_id, hub_key)
              customs[hub_key][tv_id][direction][lt] = hub_fees_and_customs_builder(direction,
                                                                                    rows[0][:mot].downcase, hub, lt, tv_id, hub_key)
            end
          end
        end
      end
      { hub_fees: hub_fees, customs: customs }
    end

    def hub_fees_and_customs_builder(direction, mot, hub, lt, tv_id, hub_key)
      {
        'fees' => {},
        'direction'         => direction,
        'mode_of_transport' => mot,
        'tenant_id'         => hub.tenant_id,
        'hub_id'            => hub.id,
        'load_type'         => lt,
        'tenant_vehicle_id' => tv_id != 'general' ? tv_id : nil,
        'counterpart_hub_id' => hub_key != 'general' ? hub_key : nil

      }
    end

    def build_charge(row)
      case row[:rate_basis].upcase
      when 'PER_SHIPMENT'
        charge = { currency: row[:currency], value: row[:shipment], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_CONTAINER'
        charge = { currency: row[:currency], value: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_BILL'
        charge = { currency: row[:currency], min: row[:minimum], value: row[:bill], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_CBM'
        charge = { currency: row[:currency], min: row[:minimum], value: row[:cbm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_KG'
        charge = { currency: row[:currency], min: row[:minimum], value: row[:kg], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_TON'
        charge = { currency: row[:currency], ton: row[:ton], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_WM'
        charge = { currency: row[:currency], value: row[:wm], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_ITEM'
        charge = { currency: row[:currency], value: row[:item], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_CBM_TON'
        charge = { currency: row[:currency], cbm: row[:cbm], ton: row[:ton], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_SHIPMENT_CONTAINER'
        charge = { currency: row[:currency], shipment: row[:shipment], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_BILL_CONTAINER'
        charge = { currency: row[:currency], bill: row[:bill], container: row[:container], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_CBM_KG'
        charge = { currency: row[:currency], cbm: row[:cbm], kg: row[:kg], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], max: row[:maximum] }
      when 'PER_KG_RANGE'
        charge = { currency: row[:currency], kg: row[:kg], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], range_min: row[:range_min], range_max: row[:range_max], max: row[:maximum] }
      when 'PER_X_KG_FLAT'
        charge = { currency: row[:currency], value: row[:kg], min: row[:minimum], rate_basis: row[:rate_basis], key: row[:fee_code], name: row[:fee], base: row[:base], max: row[:maximum] }
      end

      charge[:expiration_date] = row[:expiration_date]
      charge[:effective_date] = row[:effective_date]
      ChargeCategory.find_or_create_by!(code:row[:fee_code], name: row[:fee], tenant_id: @user.tenant_id)
      charge
    end

    def update_hashes(row, hub_fees, customs, tenant_vehicles, counterparts)
      charge = build_charge(row)
      if row[:fee_code] != 'CUST'
        hub_fees = local_charge_load_setter(
          hub_fees,
          charge,
          row[:load_type].downcase,
          row[:direction].downcase,
          tenant_vehicles["#{row[:carrier]}-#{row[:service_level]}-#{row[:mot].downcase}"] || 'general',
          row[:mot],
          counterparts["#{row[:destination]} #{hub_type_name[row[:mot].downcase]}"] || 'general'
        )
      else
        customs = local_charge_load_setter(
          customs,
          charge,
          row[:load_type].downcase,
          row[:direction].downcase,
          tenant_vehicles["#{row[:carrier]}-#{row[:service_level]}-#{row[:mot].downcase}"] || 'general',
          row[:mot],
          counterparts["#{row[:destination]} #{hub_type_name[row[:mot].downcase]}"] || 'general'
        )
    end
    end

    def update_result_and_stats_fees(hub_fees, tenant_vehicles, hub)
      hub_fees.each do |_hub_key, tv_ids|
        tv_ids.each do |_tv_id, directions|
          directions.each do |direction_key, load_type_values|
            load_type_values.each do |k, v|
              v['tenant_vehicle_id'] ||= tenant_vehicles["standard-#{v['mode_of_transport']}"]
              lc = hub.local_charges.find_by(mode_of_transport: v['mode_of_transport'], load_type: k,
                                             direction: direction_key, tenant_vehicle_id: v['tenant_vehicle_id'],
                                             counterpart_hub_id: v['counterpart_hub_id'], dangerous: false)

              if lc
                lc.update_attributes(v)
              else
                hub.local_charges.create!(v)
              end
              results[:charges] << v
              stats[:charges][:number_updated] += 1
            end
          end
        end
      end
    end

    def update_result_and_stats_customs(customs, tenant_vehicles, hub)
      customs.each do |_hub_key, tv_ids|
        tv_ids.each do |_tv_id, directions|
          directions.each do |direction_key, load_type_values|
            load_type_values.each do |k, v|
              v['tenant_vehicle_id'] ||= tenant_vehicles["standard-#{v['mode_of_transport']}"]
              cf = hub.customs_fees.find_by(mode_of_transport: v['mode_of_transport'], load_type: k, direction: direction_key, tenant_vehicle_id: v['tenant_vehicle_id'], counterpart_hub_id: v['counterpart_hub_id'])
              if cf
                cf.update_attributes(v)
              else
                hub.customs_fees.create!(v)
              end

              results[:customs] << v
              stats[:customs][:number_updated] += 1
            end
          end
        end
      end
    end

    def rate_value(charge)
      case charge[:rate_basis]
      when 'PER_KG_RANGE'
        charge[:kg]
      end
    end

    def pushable_charge(charge)
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
        effective_date: charge[:effective_date],
        expiration_date: charge[:expiration_date],
        currency:   charge[:currency],
        rate_basis: charge[:rate_basis],
        min:        charge[:min],
        range:      [
          {
            currency: charge[:currency],
            min:      charge[:range_min],
            max:      charge[:range_max],
            rate:     rate_value(charge)
          }
        ],
        key:        charge[:key],
        name:       charge[:name]
      }
    end

    def set_range_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, _mot, counterpart_hub_id)
      existing_charge = all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]['fees'][charge[:key]]
      if existing_charge && existing_charge[:range]
        all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]['fees'][charge[:key]][:range] << pushable_charge(charge)
      else
        all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]['fees'][charge[:key]] = expanded_charge(charge)
      end
      awesome_print all_charges
      all_charges
    end

    def local_charge_load_setter(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id)
      debug_message(charge)
      debug_message(all_charges)

      if counterpart_hub_id == 'general' && tenant_vehicle_id != 'general'
        all_charges.keys.each do |ac_key|
          if all_charges[ac_key][tenant_vehicle_id]
            set_general_local_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, ac_key)
          end
        end
      elsif counterpart_hub_id == 'general' && tenant_vehicle_id == 'general'
        all_charges.keys.each do |ac_key|
          all_charges[ac_key].keys.each do |tv_key|
            if all_charges[ac_key][tv_key]
              set_general_local_fee(all_charges, charge, load_type, direction, tv_key, mot, ac_key)
            end
          end
        end
      else
        if all_charges[counterpart_hub_id][tenant_vehicle_id]
          set_general_local_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id)
        end
      end
      all_charges
    end
  end
end
