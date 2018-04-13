module DocumentTools
  include PricingTools	
  def create(file, shipment)
		s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    # tixObj = firebase.get("tix/" + tid)
    objKey = 'documents/' + shipment['uuid'] +"/" + file.name
		
    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body: file, content_type: file.content_type, acl: 'private')
		shipment.documents.create(url: awsurl, shipment_id: shipment['uuid'], text: file.name)
	end
	
	def get_file_url(key)
		# signer = Aws::S3::Presigner.new(
  #     access_key_id: ENV['AWS_KEY'],
  #     secret_access_key: ENV['AWS_SECRET'],
  #     region: ENV['AWS_REGION']
  #   )
  signer = Aws::S3::Presigner.new(
      :access_key_id => ENV['AWS_KEY'],
      :secret_access_key => ENV['AWS_SECRET'],
      :region => ENV['AWS_REGION']
    )
 		@url = signer.presigned_url(:get_object, bucket: ENV['AWS_BUCKET'], key: key)	
  end
  def write_pricings_to_sheet(options)
    tenant = Tenant.find(options[:tenant_id])
    pricings = get_tenant_pricings(tenant.id)
    aux_data = {
      itineraries: {},
      nexuses: {},
      vehicle: {},
      transit_times: {}
    }
    filename = "pricings_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)
    worksheet = workbook.add_worksheet
    header_format = workbook.add_format
    header_format.set_bold
    header_values = %w(CUSTOMER_ID	NESTED	CARRIER	MOT	CARGO_TYPE	EFFECTIVE_DATE	EXPIRATION_DATE	ORIGIN	DESTINATION	TRANSIT_TIME	WM_RATE	VEHICLE	FEE	CURRENCY	RATE_BASIS	RATE_MIN	RATE	HW_THRESHOLD	HW_RATE_BASIS	MIN_RANGE	MAX_RANGE)
    header_values.each_with_index { |hv, i| worksheet.write(0, i, hv, header_format)}
    row = 1
    pricings.each_with_index do |pricing, i|
      if pricing[:expiration_date] < DateTime.now
        next
      end
      pricing_key_components = pricing[:_id].split("_")
      if !aux_data[:nexuses][pricing_key_components[0]]
        aux_data[:nexuses][pricing_key_components[0]] = Stop.find(pricing_key_components[0]).hub.nexus
        current_origin = aux_data[:nexuses][pricing_key_components[0]]
      else
        current_origin = aux_data[:nexuses][pricing_key_components[0]]
      end
      if !aux_data[:nexuses][pricing_key_components[1]]
        aux_data[:nexuses][pricing_key_components[1]] = Stop.find(pricing_key_components[1]).hub.nexus
        current_destination = aux_data[:nexuses][pricing_key_components[1]]
      else
        current_destination = aux_data[:nexuses][pricing_key_components[1]]
      end
      if !aux_data[:itineraries][pricing[:itinerary_id]]
        aux_data[:itineraries][pricing[:itinerary_id]] = Itinerary.find(pricing[:itinerary_id])
        current_itinerary = aux_data[:itineraries][pricing[:itinerary_id]]
      else
        current_itinerary = aux_data[:itineraries][pricing[:itinerary_id]]
      end
      destination_layover = ''
      origin_layover = ''
      if !aux_data[:transit_times]["#{pricing_key_components[0]}_#{pricing_key_components[1]}"]
        p current_itinerary
        tmp_layovers = current_itinerary.trips.last.layovers
        
        tmp_layovers.each do |lay| 
          if lay.stop_id == pricing_key_components[0].to_i
            origin_layover = lay
          end
          if lay.stop_id == pricing_key_components[1].to_i
            destination_layover = lay
          end
          
        end
        diff = ((destination_layover.eta - origin_layover.etd) / 86400).to_i
        aux_data[:transit_times]["#{pricing_key_components[0]}_#{pricing_key_components[1]}"] = diff
        current_transit_time = aux_data[:transit_times]["#{pricing_key_components[0]}_#{pricing_key_components[1]}"]
      else
        current_transit_time = aux_data[:transit_times]["#{pricing_key_components[0]}_#{pricing_key_components[1]}"]
      end
      
      if !aux_data[:vehicle][pricing_key_components[2]]
        aux_data[:vehicle][pricing_key_components[2]] = TransportCategory.find(pricing_key_components[2]).vehicle
        current_vehicle = aux_data[:vehicle][pricing_key_components[2]]
      else
        current_vehicle = aux_data[:vehicle][pricing_key_components[2]]
      end
      pricing[:data].each do | key, fee |
        if fee[:range] && fee[:range].length > 0
         fee[:range].each do |range_fee|
            worksheet.write(row, 3, current_itinerary.mode_of_transport)
            worksheet.write(row, 4, pricing[:load_type])
            worksheet.write(row, 5, pricing[:effective_date])
            worksheet.write(row, 6, pricing[:expiration_date])
            worksheet.write(row, 7, current_origin.name)
            worksheet.write(row, 8, current_destination.name)
            worksheet.write(row, 9, current_transit_time)
            worksheet.write(row, 10, pricing[:wm_rate])
            worksheet.write(row, 11, current_vehicle.name)
            worksheet.write(row, 12, key)
            worksheet.write(row, 13, fee[:currency])
            worksheet.write(row, 14, fee[:rate_basis])
            worksheet.write(row, 15, fee[:min])
            worksheet.write(row, 16, range_fee[:rate])
            if fee[:hw_threshold]
              worksheet.write(row, 17, fee[:hw_threshold])
            end
            if fee[:hw_rate_basis]
              worksheet.write(row, 18, fee[:hw_rate_basis])
            end
            worksheet.write(row, 19, range_fee[:min])
            worksheet.write(row, 20, range_fee[:max])
            row += 1
          end
        else
           worksheet.write(row, 3, current_itinerary.mode_of_transport)
          worksheet.write(row, 4, pricing[:load_type])
          worksheet.write(row, 5, pricing[:effective_date])
          worksheet.write(row, 6, pricing[:expiration_date])
          worksheet.write(row, 7, current_origin.name)
          worksheet.write(row, 8, current_destination.name)
          worksheet.write(row, 9, current_transit_time)
          worksheet.write(row, 10, pricing[:wm_rate])
          worksheet.write(row, 11, current_vehicle.name)
          worksheet.write(row, 12, key)
          worksheet.write(row, 13, fee[:currency])
          worksheet.write(row, 14, fee[:rate_basis])
          worksheet.write(row, 15, fee[:min])
          worksheet.write(row, 16, fee[:rate])
          if fee[:hw_threshold]
            worksheet.write(row, 17, fee[:hw_threshold])
          end
          if fee[:hw_rate_basis]
            worksheet.write(row, 18, fee[:hw_rate_basis])
          end
          row += 1
           
        end
        
      end
      if pricing[:exceptions] && pricing[:exceptions].length > 0
        pricing[:exceptions].each do |ex_pricing|
          ex_pricing[:data].each do | key, fee |
            worksheet.write(row, 1, 'TRUE')
            worksheet.write(row, 3, current_itinerary.mode_of_transport)
            worksheet.write(row, 4, pricing[:load_type])
            worksheet.write(row, 5, ex_pricing[:effective_date])
            worksheet.write(row, 6, ex_pricing[:expiration_date])
            worksheet.write(row, 7, current_origin.name)
            worksheet.write(row, 8, current_destination.name)
            worksheet.write(row, 9, current_transit_time)
            worksheet.write(row, 10, pricing[:wm_rate])
            worksheet.write(row, 11, current_vehicle.name)
            worksheet.write(row, 12, key)
            worksheet.write(row, 13, fee[:currency])
            worksheet.write(row, 14, fee[:rate_basis])
            worksheet.write(row, 15, fee[:min])
            worksheet.write(row, 16, fee[:rate])
            if fee[:hw_threshold]
              worksheet.write(row, 17, fee[:hw_threshold])
            end
            if fee[:hw_rate_basis]
              worksheet.write(row, 18, fee[:hw_rate_basis])
            end
            row += 1
          end
        end
      end
    end
    workbook.close()
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    file = open(dir)
    # byebug
    objKey = 'documents/' + tenant.subdomain + "/downloads/pricings/" + filename
		
    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body: file, content_type: 'application/vnd.ms-excel', acl: 'private')
    new_doc = tenant.documents.create(url: objKey, text: filename, doc_type: 'pricings_sheet')
		return new_doc.get_signed_url
  end

  def write_local_charges_to_sheet(options)
    tenant = Tenant.find(options[:tenant_id])
    hubs = tenant.hubs
    results_by_hub = {}
    hubs.each do |hub|
      results_by_hub[hub.name] = []
      results_by_hub[hub.name] += hub.local_charges
      results_by_hub[hub.name] += hub.customs_fees
    end

    aux_data = {
      itineraries: {},
      nexuses: {},
      vehicle: {},
      transit_times: {}
    }
    filename = "local_charges_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)
    
    header_format = workbook.add_format
    header_format.set_bold
    header_values = %w(EFFECTIVE_DATE EXPIRATION_DATE FEE	MOT	FEE_CODE	LOAD_TYPE	DIRECTION	CURRENCY	RATE_BASIS	TON	CBM	KG	ITEM	SHIPMENT	BILL	CONTAINER	MINIMUM	WM)
    results_by_hub.each do |hub, results|
      worksheet = workbook.add_worksheet(hub)
      row = 1
      header_values.each_with_index { |hv, i| worksheet.write(0, i, hv, header_format)}
      results.each do |result|
        %w(import export).each do |dir|
          result[dir].deep_symbolize_keys!
          result[dir].each do |key, fee|
            
              worksheet.write(row, 0, fee[:effective_date])
              worksheet.write(row, 1, fee[:expiration_date])
              worksheet.write(row, 2, fee[:name])
              worksheet.write(row, 3, result[:mode_of_transport])
              worksheet.write(row, 4, key)
              worksheet.write(row, 5, result[:load_type])
              worksheet.write(row, 6, dir)
              worksheet.write(row, 7, result[:currency])
              worksheet.write(row, 8, fee[:rate_basis])
              case fee[:rate_basis]
              when 'PER_CONTAINER'
                worksheet.write(row, 15, fee[:value])
              when 'PER_ITEM'
                worksheet.write(row, 12, fee[:value])
              when 'PER_BILL'
                worksheet.write(row, 14, fee[:value])
              when 'PER_SHIPMENT'
                worksheet.write(row, 13, fee[:value])
              when 'PER_CBM_TON'
                worksheet.write(row, 9, fee[:ton])
                worksheet.write(row, 10, fee[:cbm])
                worksheet.write(row, 16, fee[:min])
              when 'PER_CBM_KG'
                worksheet.write(row, 11, fee[:kg])
                worksheet.write(row, 10, fee[:cbm])
                worksheet.write(row, 16, fee[:min])
              when 'PER_WM'
                worksheet.write(row, 17, fee[:value])
             
              end
               row += 1
          end
        end
      end
    end
    workbook.close()
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    file = open(dir)
    # byebug
    objKey = 'documents/' + tenant.subdomain + "/downloads/service_charges/" + filename
		
    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body: file, content_type: 'application/vnd.ms-excel', acl: 'private')
    new_doc = tenant.documents.create(url: objKey, text: filename, doc_type: 'local_charges_sheet')
		return new_doc.get_signed_url
  end

  def write_hubs_to_sheet(options)
    tenant = Tenant.find(options[:tenant_id])
    hubs = tenant.hubs
    filename = "hubs_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)
    
    header_format = workbook.add_format
    header_format.set_bold
    worksheet = workbook.add_worksheet()
    header_values = %w(STATUS	TYPE	NAME	CODE	LATITUDE	LONGITUDE	COUNTRY	FULL_ADDRESS	)
    row = 1
    header_values.each_with_index { |hv, i| worksheet.write(0, i, hv, header_format)}
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
    workbook.close()
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    file = open(dir)
    # byebug
    objKey = 'documents/' + tenant.subdomain + "/downloads/hubs/" + filename
		
    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body: file, content_type: 'application/vnd.ms-excel', acl: 'private')
    new_doc = tenant.documents.create(url: objKey, text: filename, doc_type: 'hubs_sheet')
		return new_doc.get_signed_url
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
      filename = "schedules_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    end
    
    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)
    
    header_format = workbook.add_format
    header_format.set_bold
    worksheet = workbook.add_worksheet()
    header_values = %w(FROM	TO	CLOSING_DATE	ETD	ETA	TRANSIT_TIME SERVICE_LEVEL MODE_OF_TRANSPORT VESSEL VOYAGE_CODE)
    row = 1
    header_values.each_with_index { |hv, i| worksheet.write(0, i, hv, header_format)}
    trips.each do |trip|
      layovers = trip.layovers.order(:stop_index)
      if layovers.length < 2
        next
      end
      diff = (layovers.last.eta - layovers.first.etd) / 86400
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
    workbook.close()
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    file = open(dir)
    # byebug
    objKey = 'documents/' + tenant.subdomain + "/downloads/schedules/" + filename
		
    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body: file, content_type: 'application/vnd.ms-excel', acl: 'private')
    new_doc = tenant.documents.create(url: objKey, text: filename, doc_type: 'schedules_sheet')
		return new_doc.get_signed_url
  end

  def write_clients_to_sheet(options)
    tenant = Tenant.find(options[:tenant_id])
    filename = "schedules_#{DateTime.now.strftime('%Y-%m-%d')}.xlsx"
    dir = "tmp/#{filename}"
    workbook = WriteXLSX.new(dir)
    
    header_format = workbook.add_format
    header_format.set_bold
    worksheet = workbook.add_worksheet()
    header_values = %w(FROM	TO	CLOSING_DATE	ETD	ETA	TRANSIT_TIME SERVICE_LEVEL MODE_OF_TRANSPORT VESSEL VOYAGE_CODE)
    row = 1
    header_values.each_with_index { |hv, i| worksheet.write(0, i, hv, header_format)}
    trips.each do |trip|
      layovers = trip.layovers.order(:stop_index)
      if layovers.length < 2
        next
      end
      diff = (layovers.last.eta - layovers.first.etd) / 86400
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
    workbook.close()
    s3 = Aws::S3::Client.new(
      access_key_id: ENV['AWS_KEY'],
      secret_access_key: ENV['AWS_SECRET'],
      region: ENV['AWS_REGION']
    )
    file = open(dir)
    # byebug
    objKey = 'documents/' + tenant.subdomain + "/downloads/schedules/" + filename
		
    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body: file, content_type: 'application/vnd.ms-excel', acl: 'private')
    new_doc = tenant.documents.create(url: objKey, text: filename, doc_type: 'schedules_sheet')
		return new_doc.get_signed_url
  end

end