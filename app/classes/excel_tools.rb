# frozen_string_literal: true

DEBUG = false

module ExcelTools
  include ImageTools
  include PricingTools

  def load_hub_images(params)
    xlsx = Roo::Spreadsheet.open(params['xlsx'])
    first_sheet = xlsx.sheet(xlsx.sheets.first)

    hub_rows = first_sheet.parse(hub_name: 'NAME', url: 'URL')

    hub_rows.each do |hub_row|
      imgstr = reduce_and_upload(hub_row[:hub_name], hub_row[:url])
      nexus = Address.find_by_name(hub_row[:hub_name])
      nexus.update_attributes(photo: imgstr[:sm])
      nexus.save!
    end
  end

  def price_split(basis, string)
    vals = string.split(' ')
    {
      'currency' => vals[1],
      'rate' => vals[0].to_i,
      'rate_basis' => basis
    }
  end

  def rate_key(cargo_class)
    base_str = cargo_class.dup
    base_str.slice! cargo_class.rindex('f')
    "#{base_str}_rate".to_sym
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

  def set_regular_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, _mot, counterpart_hub_id)
    if load_type == 'fcl'
      Container::CARGO_CLASSES.each do |lt|
        all_charges[counterpart_hub_id][tenant_vehicle_id][direction][lt]['fees'][charge[:key]] = charge
      end
    else
      all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]['fees'][charge[:key]] = charge
    end
    all_charges
  end

  def set_general_local_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id)
    if charge[:rate_basis].include? 'RANGE'
      if load_type == 'fcl'
        Container::CARGO_CLASSES.each do |lt|
          set_range_fee(all_charges, charge, lt, direction, tenant_vehicle_id, mot, counterpart_hub_id)
        end
      else
        set_range_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id)
      end
    else
      set_regular_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, mot, counterpart_hub_id)
    end
  end

  def set_range_fee(all_charges, charge, load_type, direction, tenant_vehicle_id, _mot, counterpart_hub_id)
    case charge[:rate_basis]
    when 'PER_KG_RANGE'
      rate_value = charge[:kg]
    end
    existing_charge = all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]['fees'][charge[:key]]
    if existing_charge && existing_charge[:range]
      all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]['fees'][charge[:key]][:range] << {
        currency: charge[:currency],
        rate_basis: charge[:rate_basis],
        min: charge[:range_min],
        max: charge[:range_max],
        rate: rate_value
      }
    else
      all_charges[counterpart_hub_id][tenant_vehicle_id][direction][load_type]['fees'][charge[:key]] = {
        effective_date: charge[:effective_date],
        expiration_date: charge[:expiration_date],
        currency: charge[:currency],
        rate_basis: charge[:rate_basis],
        min: charge[:min],
        range: [
          {
            currency: charge[:currency],
            min: charge[:range_min],
            max: charge[:range_max],
            rate: rate_value
          }
        ],
        key: charge[:key],
        name: charge[:name]
      }
    end
    all_charges
  end

  def debug_message(message)
    puts message if DEBUG
  end

  def generate_meta_from_sheet(sheet)
    meta = {}
    sheet.row(1).each_with_index do |key, i|
      next if key.nil?

      meta[key.downcase] = sheet.row(2)[i]
    end
    meta.deep_symbolize_keys!
  end

  def find_geometry(idents_and_country)
    geometry = Geometry.cascading_find_by_names(
      idents_and_country[:sub_ident],
      idents_and_country[:ident]
    )

    if geometry.nil?
      geocoder_results = Geocoder.search(idents_and_country.values.join(' '))
      coordinates = geocoder_results.first.geometry['location']
      geometry = Geometry.find_by_coordinates(coordinates['lat'], coordinates['lng'])
    end

    raise "no geometry found for #{idents_and_country.values.join(', ')}" if geometry.nil?

    geometry
  end

  def determine_identifier_type_and_modifier(identifier_type)
    if identifier_type == 'CITY'
      'geometry_id'
    elsif identifier_type.include?('_')
      identifier_type.split('_').map(&:downcase)
    elsif identifier_type.include?(' ')
      identifier_type.split(' ').map(&:downcase)
    else
      [identifier_type.downcase, false]
    end
  end
end
