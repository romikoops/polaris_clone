module DocumentTools	
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
    filename = DateTime.now.strftime('%Y-%m-%d')
    dir = "tmp/pricings_#{filename}.xlsx"
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
    objKey = 'documents/' + tenant.subdomain + "/downloads/pricings" + filename
		
    awsurl = "https://s3-eu-west-1.amazonaws.com/imcdev/" + objKey
    s3.put_object(bucket: ENV['AWS_BUCKET'], key: objKey, body: file, content_type: file.content_type, acl: 'private')
    tenant.documents.create(url: awsurl, text: file.name)
		return get_file_url(objKey)
  end
end