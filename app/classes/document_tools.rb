# frozen_string_literal: true

module DocumentTools
  include PricingTools
  def create(file, shipment)
    s3 = Aws::S3::Client.new(
      access_key_id:     ENV["AWS_KEY"],
      secret_access_key: ENV["AWS_SECRET"],
      region:            ENV["AWS_REGION"]
    )
    # tixObj = firebase.get("tix/" + tid)
    objKey = "documents/" + shipment["uuid"] + "/" + file.name

    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV["AWS_BUCKET"], key: objKey, body: file, content_type: file.content_type, acl: "private")
    shipment.documents.create(url: awsurl, shipment_id: shipment["uuid"], text: file.name)
  end

  def get_file_url(key)
    # signer = Aws::S3::Presigner.new(
    #     access_key_id: ENV['AWS_KEY'],
    #     secret_access_key: ENV['AWS_SECRET'],
    #     region: ENV['AWS_REGION']
    #   )
    signer = Aws::S3::Presigner.new(
      access_key_id:     ENV["AWS_KEY"],
      secret_access_key: ENV["AWS_SECRET"],
      region:            ENV["AWS_REGION"]
    )
    @url = signer.presigned_url(:get_object, bucket: ENV["AWS_BUCKET"], key: key)
  end

  def write_local_charges_to_sheet(options)
    tenant = Tenant.find(options[:tenant_id])

    hubs = options[:mot] ? tenant.hubs.where(hub_type: options[:mot]) : tenant.hubs
    results_by_hub = {}
    hubs.each do |hub|
      results_by_hub[hub.name] = []
      results_by_hub[hub.name] += hub.local_charges.map(&:as_json)
      results_by_hub[hub.name] += hub.customs_fees.map(&:as_json)
    end

    aux_data = {
      itineraries:   {},
      nexuses:       {},
      vehicle:       {},
      transit_times: {}
    }
    filename = options[:mot] ? "#{options[:mot]}_local_charges_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx" : "local_charges_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)

    header_format = workbook.add_format
    header_format.set_bold
    header_values = %w[EFFECTIVE_DATE EXPIRATION_DATE DESTINATION SERVICE_LEVEL FEE	MOT	FEE_CODE	LOAD_TYPE	DIRECTION	CURRENCY	RATE_BASIS	TON	CBM	KG	ITEM	SHIPMENT	BILL	CONTAINER	MINIMUM	WM]
    
    results_by_hub.each do |hub, results|
      worksheet = workbook.add_worksheet(hub)
      row = 1
      header_values.each_with_index { |hv, i| worksheet.write(0, i, hv, header_format) }
      results.each do |result|
          result.deep_symbolize_keys!
          counterpart_hub_name = result[:counterpart_hub_id] ? Hub.find(result[:counterpart_hub_id]).name : ""
          tenant_vehicle_name = result[:tenant_vehicle_id] ? TenantVehicle.find(result[:tenant_vehicle_id]).name : ""
          next if !result[:fees]
          result[:fees].each do |key, fee|
            if fee[:range] && !fee[:range].empty?
              fee[:range].each do |range_fee|
                worksheet.write(row, 0, fee[:effective_date])
                worksheet.write(row, 1, fee[:expiration_date])
                worksheet.write(row, 2, counterpart_hub_name)
                worksheet.write(row, 3, tenant_vehicle_name)
                worksheet.write(row, 4, fee[:name])
                worksheet.write(row, 5, result[:mode_of_transport])
                worksheet.write(row, 6, key)
                worksheet.write(row, 7, result[:load_type])
                worksheet.write(row, 8, result[:direction])
                worksheet.write(row, 9, fee[:currency])
                worksheet.write(row, 10, fee[:rate_basis])
                case fee[:rate_basis]
                when "PER_CONTAINER"
                  worksheet.write(row, 17, fee[:value])
                when "PER_ITEM"
                  worksheet.write(row, 14, fee[:value])
                when "PER_BILL"
                  worksheet.write(row, 16, fee[:value])
                when "PER_SHIPMENT"
                  worksheet.write(row, 15, fee[:value])
                when "PER_CBM_TON"
                  worksheet.write(row, 11, fee[:ton])
                  worksheet.write(row, 12, fee[:cbm])
                  worksheet.write(row, 18, fee[:min])
                when "PER_CBM_KG"
                  worksheet.write(row, 13, fee[:kg])
                  worksheet.write(row, 12, fee[:cbm])
                  worksheet.write(row, 18, fee[:min])
                when "PER_WM"
                  worksheet.write(row, 19, range_fee[:rate])
                  worksheet.write(row, 18, fee[:min])
                when "PER_KG"
                  worksheet.write(row, 13, range_fee[:rate])
                  worksheet.write(row, 18, fee[:min])
                end
                worksheet.write(row, 20, range_fee[:min])
                worksheet.write(row, 21, range_fee[:max])
                row += 1
              end
            else
              worksheet.write(row, 0, fee[:effective_date])
              worksheet.write(row, 1, fee[:expiration_date])
              worksheet.write(row, 2, counterpart_hub_name)
              worksheet.write(row, 3, tenant_vehicle_name)
              worksheet.write(row, 4, fee[:name])
              worksheet.write(row, 5, result[:mode_of_transport])
              worksheet.write(row, 6, key)
              worksheet.write(row, 7, result[:load_type])
              worksheet.write(row, 8, result[:direction])
              worksheet.write(row, 9, fee[:currency])
              worksheet.write(row, 10, fee[:rate_basis])
              case fee[:rate_basis]
              when "PER_CONTAINER"
                worksheet.write(row, 17, fee[:value])
              when "PER_ITEM"
                worksheet.write(row, 14, fee[:value])
              when "PER_BILL"
                worksheet.write(row, 16, fee[:value])
              when "PER_SHIPMENT"
                worksheet.write(row, 15, fee[:value])
              when "PER_CBM_TON"
                worksheet.write(row, 11, fee[:ton])
                worksheet.write(row, 12, fee[:cbm])
                worksheet.write(row, 18, fee[:min])
              when "PER_CBM_KG"
                worksheet.write(row, 13, fee[:kg])
                worksheet.write(row, 12, fee[:cbm])
                worksheet.write(row, 18, fee[:min])
              when "PER_WM"
                worksheet.write(row, 19, fee[:value])
              when "PER_KG"
                worksheet.write(row, 13, fee[:kg])
                worksheet.write(row, 18, fee[:min])
              end
              row += 1
            end
        end
      end
    end
    workbook.close
    s3 = Aws::S3::Client.new(
      access_key_id:     ENV["AWS_KEY"],
      secret_access_key: ENV["AWS_SECRET"],
      region:            ENV["AWS_REGION"]
    )
    file = open(dir)
    # byebug
    objKey = "documents/" + tenant.subdomain + "/downloads/service_charges/" + filename

    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV["AWS_BUCKET"], key: objKey, body: file, content_type: "application/vnd.ms-excel", acl: "private")
    new_doc = tenant.documents.create(url: objKey, text: filename, doc_type: "local_charges_sheet")
    new_doc.get_signed_url
  end

  def write_hubs_to_sheet(options)
    tenant = Tenant.find(options[:tenant_id])
    hubs = tenant.hubs
    filename = "hubs_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)

    header_format = workbook.add_format
    header_format.set_bold
    worksheet = workbook.add_worksheet
    header_values = %w[STATUS	TYPE	NAME	CODE	LATITUDE	LONGITUDE	COUNTRY	FULL_ADDRESS	]
    row = 1
    header_values.each_with_index { |hv, i| worksheet.write(0, i, hv, header_format) }
    hubs.each do |hub|
      worksheet.write(row, 0, hub.hub_status)
      worksheet.write(row, 1, hub.hub_type)
      worksheet.write(row, 2, hub.nexus.name)
      worksheet.write(row, 3, hub.hub_code)
      worksheet.write(row, 4, hub.location.latitude)
      worksheet.write(row, 5, hub.location.longitude)
      worksheet.write(row, 6, hub.location.country)
      worksheet.write(row, 7, hub.location.geocoded_address)
      row += 1
    end
    workbook.close
    s3 = Aws::S3::Client.new(
      access_key_id:     ENV["AWS_KEY"],
      secret_access_key: ENV["AWS_SECRET"],
      region:            ENV["AWS_REGION"]
    )
    file = open(dir)
    # byebug
    objKey = "documents/" + tenant.subdomain + "/downloads/hubs/" + filename

    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV["AWS_BUCKET"], key: objKey, body: file, content_type: "application/vnd.ms-excel", acl: "private")
    new_doc = tenant.documents.create(url: objKey, text: filename, doc_type: "hubs_sheet")
    new_doc.get_signed_url
  end

  def write_schedules_to_sheet(options)
    tenant = Tenant.find(options[:tenant_id])
    if options[:mode_of_transport] && !options[:itinerary_id]
      trips = Trip.joins("INNER JOIN itineraries ON trips.itinerary_id = itineraries.id AND itineraries.mode_of_transport = '#{options[:mode_of_transport]}' AND itineraries.tenant_id = #{options[:tenant_id]}").order(:start_date)
      filename = "#{options[:mode_of_transport]}_schedules_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    elsif options[:itinerary_id]
      itinerary = Itinerary.find(options[:itinerary_id])
      trips = itinerary.trips.order(:start_date)
      filename = "#{itinerary.name}_schedules_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    else
      trips = Trip.joins("INNER JOIN itineraries ON trips.itinerary_id = itineraries.id AND itineraries.tenant_id = #{options[:tenant_id]}").order(:start_date)
      filename = "#{tenant.name}_schedules_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    end

    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)

    header_format = workbook.add_format
    header_format.set_bold
    worksheet = workbook.add_worksheet
    header_values = %w[FROM	TO	CLOSING_DATE	ETD	ETA	TRANSIT_TIME SERVICE_LEVEL MODE_OF_TRANSPORT VESSEL VOYAGE_CODE]
    row = 1
    header_values.each_with_index { |hv, i| worksheet.write(0, i, hv, header_format) }
    trips.each do |trip|
      layovers = trip.layovers.order(:stop_index)
      next if layovers.length < 2
      diff = (layovers.last.eta - layovers.first.etd) / 86_400
      worksheet.write(row, 0, layovers.first.stop.hub.nexus.name)
      worksheet.write(row, 1, layovers.last.stop.hub.nexus.name)
      worksheet.write(row, 2, layovers.first.closing_date)
      worksheet.write(row, 3, layovers.first.etd)
      worksheet.write(row, 4, layovers.last.eta)
      worksheet.write(row, 5, diff)
      worksheet.write(row, 6, trip.vehicle.name)
      worksheet.write(row, 7, trip.itinerary.mode_of_transport)
      worksheet.write(row, 8, trip.vessel)
      worksheet.write(row, 9, trip.voyage_code)

      row += 1
    end
    workbook.close
    s3 = Aws::S3::Client.new(
      access_key_id:     ENV["AWS_KEY"],
      secret_access_key: ENV["AWS_SECRET"],
      region:            ENV["AWS_REGION"]
    )
    file = open(dir)
    # byebug
    objKey = "documents/" + tenant.subdomain + "/downloads/schedules/" + filename

    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV["AWS_BUCKET"], key: objKey, body: file, content_type: "application/vnd.ms-excel", acl: "private")
    new_doc = tenant.documents.create(url: objKey, text: filename, doc_type: "schedules_sheet")
    new_doc.get_signed_url
  end

  def write_clients_to_sheet(options)
    tenant = Tenant.find(options[:tenant_id])
    filename = "schedules_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)

    header_format = workbook.add_format
    header_format.set_bold
    worksheet = workbook.add_worksheet
    header_values = %w[FROM	TO	CLOSING_DATE	ETD	ETA	TRANSIT_TIME SERVICE_LEVEL MODE_OF_TRANSPORT VESSEL VOYAGE_CODE]
    row = 1
    header_values.each_with_index { |hv, i| worksheet.write(0, i, hv, header_format) }
    trips.each do |trip|
      layovers = trip.layovers.order(:stop_index)
      next if layovers.length < 2
      diff = (layovers.last.eta - layovers.first.etd) / 86_400
      worksheet.write(row, 0, layovers.first.stop.hub.nexus.name)
      worksheet.write(row, 1, layovers.last.stop.hub.nexus.name)
      worksheet.write(row, 2, layovers.first.closing_date)
      worksheet.write(row, 3, layovers.first.etd)
      worksheet.write(row, 4, layovers.last.eta)
      worksheet.write(row, 5, diff)
      worksheet.write(row, 6, trip.vehicle.name)
      worksheet.write(row, 7, trip.itinerary.mode_of_transport)
      worksheet.write(row, 8, trip.vessel)
      worksheet.write(row, 9, trip.voyage_code)

      row += 1
    end
    workbook.close
    s3 = Aws::S3::Client.new(
      access_key_id:     ENV["AWS_KEY"],
      secret_access_key: ENV["AWS_SECRET"],
      region:            ENV["AWS_REGION"]
    )
    file = open(dir)
    # byebug
    objKey = "documents/" + tenant.subdomain + "/downloads/schedules/" + filename

    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV["AWS_BUCKET"], key: objKey, body: file, content_type: "application/vnd.ms-excel", acl: "private")
    new_doc = tenant.documents.create(url: objKey, text: filename, doc_type: "schedules_sheet")
    new_doc.get_signed_url
  end

  def write_trucking_to_sheet(options)
    tenant = Tenant.find(options[:tenant_id])
    hub = Hub.find(options[:hub_id])
    target_load_type = options[:load_type]
    filename = "#{hub.name}_#{target_load_type}_trucking_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)
    unfiltered_results = TruckingPricing.find_by_hub_id(options[:hub_id])
    # byebug
    carriage_reducer = {}
    results_by_truck_type = {}
    dir_fees = {}

    unfiltered_results.map do |ufr|
      ufr_key = ""
      if ufr["truckingPricing"].load_type == target_load_type && ufr["zipcode"]
        ufr_key = "#{ufr['zipcode'][0]} - #{ufr['zipcode'][1]}_#{ufr['truckingPricing'].truck_type}"
        unless results_by_truck_type[ufr["truckingPricing"].truck_type]
          results_by_truck_type[ufr["truckingPricing"].truck_type] = []
        end
      elsif ufr["truckingPricing"].load_type == target_load_type && ufr["city"]
        ufr_key = "#{ufr['city'][0]}_#{ufr['truckingPricing'].truck_type}"
        unless results_by_truck_type[ufr["truckingPricing"].truck_type]
          results_by_truck_type[ufr["truckingPricing"].truck_type] = []
        end
      elsif ufr["truckingPricing"].load_type == target_load_type && ufr["distance"]
        ufr_key = "#{ufr['distance'][0]} - #{ufr['distance'][1]}_#{ufr['truckingPricing'].truck_type}"
        unless results_by_truck_type[ufr["truckingPricing"].truck_type]
          results_by_truck_type[ufr["truckingPricing"].truck_type] = []
        end
      end
      if ufr["truckingPricing"].load_type == target_load_type && ufr["truckingPricing"].carriage == "pre"
        unless ufr["truckingPricing"].fees.empty?
          dir_fees[ufr["truckingPricing"].truck_type] = {} unless dir_fees[ufr["truckingPricing"].truck_type]
          awesome_print ufr["truckingPricing"].fees
          dir_fees[ufr["truckingPricing"].truck_type][:pre] = ufr["truckingPricing"].fees
        end
      end
      if ufr["truckingPricing"].load_type == target_load_type && ufr["truckingPricing"].carriage == "on"
        unless ufr["truckingPricing"].fees.empty?
          dir_fees[ufr["truckingPricing"].truck_type] = {} unless dir_fees[ufr["truckingPricing"].truck_type]
          awesome_print ufr["truckingPricing"].fees
          dir_fees[ufr["truckingPricing"].truck_type][:on] = ufr["truckingPricing"].fees
        end
      end
      if ufr["truckingPricing"].load_type == target_load_type && !carriage_reducer[ufr_key]
        carriage_reducer[ufr_key] = true
        results_by_truck_type[ufr["truckingPricing"].truck_type] << ufr
      end
    end

    results_by_truck_type = results_by_truck_type.each do |tt, array|
      if array.empty?
        results_by_truck_type.delete(tt)
        dir_fees.delete(tt)
      end
    end
    first_result = results_by_truck_type.first[1].first
    awesome_print first_result
    unless first_result

    end

    currency = first_result["truckingPricing"].rates.first[1][0]["rate"]["currency"]
    rate_basis = first_result["truckingPricing"].rates.first[1][0]["rate"]["rate_basis"]
    # truck_type = first_result["truckingPricing"].truck_type
    courier = first_result["truckingPricing"].courier
    header_format = workbook.add_format
    header_format.set_bold
    zone_sheet = workbook.add_worksheet("Zones")
    rates_sheet = workbook.add_worksheet("Rates")
    fees_sheet = workbook.add_worksheet("Fees")

    # Write Zones with identifiers

    header_values = %w[ZONE IDENTIFIER RANGE COUNTRY_CODE]
    row = 1
    identifier = ""

    header_values.each_with_index { |hv, i| zone_sheet.write(0, i, hv, header_format) }
    zone_row = 1
    results_by_truck_type.each do |_truck_type, results|
      results.each_with_index do |result, i|
        zone_sheet.write(zone_row, 0, i)
        if result["zipcode"]
          identifier = "zipcode"
          if result["zipcode"][0] == result["zipcode"][1]
            zone_sheet.write(zone_row, 1, result["zipcode"][1])
          else
            zone_sheet.write(zone_row, 2, "#{result['zipcode'][0]} - #{result['zipcode'][1]}")
          end
        end
        if result["city"]
          identifier = "city"
          zone_sheet.write(zone_row, 1, result["city"][0])
        end
        if result["distance"]
          identifier = "distance"
          if result["distance"][0] == result["distance"][1]
            zone_sheet.write(zone_row, 1, result["distance"][1])
          else
            zone_sheet.write(zone_row, 2, "#{result['distance'][0]} - #{result['distance'][1]}")
          end
        end
        zone_row += 1
        # row += 1
      end
    end
    zone_sheet.write(1, 6, "Origin City")
    zone_sheet.write(1, 7, hub.nexus.name)
    zone_sheet.write(2, 6, "Currency")
    zone_sheet.write(2, 7, currency)
    zone_sheet.write(3, 6, "Load Meterage Ratio")
    zone_sheet.write(3, 7, first_result["truckingPricing"][:load_meterage]["ratio"])
    zone_sheet.write(4, 6, "Load Meterage Limit")
    zone_sheet.write(4, 7, first_result["truckingPricing"][:load_meterage]["height_limit"])
    zone_sheet.write(5, 6, "CBM Ratio")
    zone_sheet.write(5, 7, first_result["truckingPricing"][:cbm_ratio])
    zone_sheet.write(6, 6, "Rate Basis")
    zone_sheet.write(6, 7, rate_basis)
    zone_sheet.write(7, 6, "Base")
    zone_sheet.write(7, 7, first_result["truckingPricing"].rates.first[1][0]["rate"]["base"] || 1)
    zone_sheet.write(8, 6, "Load Type")
    zone_sheet.write(8, 7, first_result["truckingPricing"].load_type)
    zone_sheet.write(9, 6, "Identifier")
    zone_sheet.write(9, 7, identifier)
    zone_sheet.write(10, 6, "Courier")
    zone_sheet.write(10, 7, courier.name)

    # Write zones with rates to Rate Sheet

    rates_sheet.write(1, 0, "ZONE")
    rates_sheet.write(1, 1, "TRUCK_TYPE")
    rates_sheet.write(1, 2, "MIN")
    rates_sheet.write(2, 0, "MIN")
    minimums = {}
    row = 3
    x = 3

    first_result["truckingPricing"].rates.each do |key, rates_array|
      rates_array.each do |rate|
        next unless rate
        rates_sheet.write(0, x, key.downcase)
        rates_sheet.write(1, x, "#{rate["min_#{key}"]} - #{rate["max_#{key}"]}")
        x += 1
      end
    end
    results_by_truck_type.each do |truck_type, results|
      results.each_with_index do |result, i|
        rates_sheet.write(row, 0, i)
        rates_sheet.write(row, 1, truck_type)
        rates_sheet.write(row, 2, result["truckingPricing"].rates.first[1][0]["min_value"])
        minimums[i] = result["truckingPricing"].rates.first[1][0]["min_value"]
        x = 3
        result["truckingPricing"].rates.each do |_key, rates_array|
          rates_array.each do |rate|
            next unless rate
            if rate["min_value"] != minimums[i]
              rates_sheet.write(3, x, rate["min_value"].round(2))
            else
              rates_sheet.write(3, x, 0)
            end
            rates_sheet.write(row, x, rate["rate"]["value"].round(2))
            x += 1
          end
        end
        row += 1
      end
    end
    # Write fees to sheet

    fee_header_values = %w[FEE	MOT	FEE_CODE	TRUCK_TYPE	DIRECTION	CURRENCY	RATE_BASIS	TON	CBM	KG	ITEM	SHIPMENT	BILL	CONTAINER	MINIMUM	WM	PERCENTAGE]
    row = 1
    fee_header_values.each_with_index { |hv, i| fees_sheet.write(0, i, hv, header_format) }
    dir_fees.deep_symbolize_keys!
    awesome_print dir_fees
    dir_fees.each do |truck_type, directions|
      directions.each do |carriage_dir, fees|
        fees.each do |key, fee|
          awesome_print fee
          fees_sheet.write(row, 0, fee[:name])
          fees_sheet.write(row, 1, hub.hub_type)
          fees_sheet.write(row, 2, key)
          fees_sheet.write(row, 3, truck_type)
          fees_sheet.write(row, 4, carriage_dir)
          fees_sheet.write(row, 5, currency)
          fees_sheet.write(row, 6, rate_basis)
          case fee[:rate_basis]
          when "PER_CONTAINER"
            fees_sheet.write(row, 13, fee[:value])
          when "PER_ITEM"
            fees_sheet.write(row, 10, fee[:value])
          when "PER_BILL"
            fees_sheet.write(row, 12, fee[:value])
          when "PER_SHIPMENT"
            fees_sheet.write(row, 11, fee[:value])
          when "PER_CBM_TON"
            fees_sheet.write(row, 7, fee[:ton])
            fees_sheet.write(row, 8, fee[:cbm])
            fees_sheet.write(row, 14, fee[:min])
          when "PER_CBM_KG"
            fees_sheet.write(row, 9, fee[:kg])
            fees_sheet.write(row, 8, fee[:cbm])
            fees_sheet.write(row, 14, fee[:min])
          when "PER_WM"
            fees_sheet.write(row, 15, fee[:value])
          when "PERCENTAGE"
            fees_sheet.write(row, 16, fee[:value])
          end
          row += 1
        end
      end
    end
    workbook.close
    s3 = Aws::S3::Client.new(
      access_key_id:     ENV["AWS_KEY"],
      secret_access_key: ENV["AWS_SECRET"],
      region:            ENV["AWS_REGION"]
    )
    file = open(dir)
    # byebug
    objKey = "documents/" + tenant.subdomain + "/downloads/trucking/" + filename

    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV["AWS_BUCKET"], key: objKey, body: file, content_type: "application/vnd.ms-excel", acl: "private")
    new_doc = tenant.documents.create(url: objKey, text: filename, doc_type: "schedules_sheet")
    new_doc.get_signed_url
  end

  def gdpr_download(user_id)
    user = User.find(user_id)
    user_contacts = user.contacts.where(alias: false)
    user_aliases = user.contacts.where(alias: true)
    user_shipments = user.shipments
    user_messages = user.conversations
    user_locations = user.user_locations
    filename = "#{user.first_name}_#{user.last_name}_GDPR.xlsx"
    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)

    header_format = workbook.add_format
    header_format.set_bold
    user_sheet = workbook.add_worksheet("Account")
    user_keys = %w[sign_in_count
                   last_sign_in_at
                   last_sign_in_ip
                   nickname
                   email
                   company_name
                   first_name
                   last_name
                   phone
                   currency
                   vat_number
                   uid]
    row = 1

    user_keys.each do |k|
      user_sheet.write(row, 0, k.humanize)
      user_sheet.write(row, 1, user[k])
      row += 1
    end
    alias_sheet = workbook.add_worksheet("Aliases")
    row = 1
    user_aliases.each do |ua|
      ua.as_json.each do |k, value|
        if k.to_s == "location_id"
          loc = Location.find(value)
          loc.set_geocoded_address_from_fields! unless loc.geocoded_address
          alias_sheet.write(row, 0, k.humanize)
          alias_sheet.write(row, 1, loc.geocoded_address)
        else
          alias_sheet.write(row, 0, k.humanize)
          alias_sheet.write(row, 1, value)
        end
        row += 1
      end
      row += 1
    end

    contacts_sheet = workbook.add_worksheet("Contacts")
    row = 1
    user_contacts.each do |uc|
      uc.as_json.each do |k, value|
        if k.to_s == "location_id"
          loc = Location.find(value)
          loc.set_geocoded_address_from_fields! unless loc.geocoded_address
          contacts_sheet.write(row, 0, k.humanize)
          contacts_sheet.write(row, 1, loc.geocoded_address)
        else
          contacts_sheet.write(row, 0, k.humanize)
          contacts_sheet.write(row, 1, value)
        end
        row += 1
      end
      row += 1
    end
    shipment_sheet = workbook.add_worksheet("Shipments")
    shipment_headers = %w[origin_id
                          destination_id
                          imc_reference
                          status
                          load_type
                          has_pre_carriage
                          has_on_carriage
                          planned_eta
                          planned_etd
                          total_price
                          insurance
                          customs]
    shipment_headers.each_with_index do |header, i|
      shipment_sheet.write(0, i, header.humanize)
    end
    row = 1
    user_shipments.each do |shipment|
      shipment_sheet.write(row, 0, shipment.origin.geocoded_address)
      shipment_sheet.write(row, 1, shipment.destination.geocoded_address)
      shipment_sheet.write(row, 2, shipment.imc_reference)
      shipment_sheet.write(row, 3, shipment.status)
      shipment_sheet.write(row, 4, shipment.load_type.humanize)
      shipment_sheet.write(row, 5, shipment.has_pre_carriage.to_s)
      shipment_sheet.write(row, 6, shipment.has_on_carriage.to_s)
      shipment_sheet.write(row, 7, shipment.planned_etd)
      shipment_sheet.write(row, 8, shipment.planned_eta)
      shipment_sheet.write(row, 9, "#{shipment.total_price['currency']} #{shipment.total_price['value'].to_d.round(2)}")
      shipment_sheet.write(row, 10, shipment.insurance && shipment.insurance["val"] ? "#{shipment.insurance['currency']} #{shipment.insurance['val'].to_d.round(2)}" : "N/A")
      shipment_sheet.write(row, 11, shipment.customs && shipment.customs["val"] ? "#{shipment.customs['currency']} #{shipment.customs['val'].to_d.round(2)}" : "N/A")
    end
    workbook.close
    s3 = Aws::S3::Client.new(
      access_key_id:     ENV["AWS_KEY"],
      secret_access_key: ENV["AWS_SECRET"],
      region:            ENV["AWS_REGION"]
    )
    file = open(dir)
    # byebug
    objKey = "documents/" + user.tenant.subdomain + "/downloads/gdpr/" + filename

    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV["AWS_BUCKET"], key: objKey, body: file, content_type: "application/vnd.ms-excel", acl: "private")
    new_doc = user.documents.create(url: objKey, text: filename, doc_type: "gdpr")
    new_doc.get_signed_url
  end
end
