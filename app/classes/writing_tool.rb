# frozen_string_literal: true

module WritingTool
  def write_to_aws(dir, tenant, filename, doc_type)
    file = open(dir)
    obj_key = "documents/#{tenant.subdomain}/downloads/#{doc_type}/#{filename}"
    aws_client.put_object(bucket: ENV["AWS_BUCKET"], key: obj_key, body: file, content_type: "application/vnd.ms-excel", acl: "private")
    new_doc = tenant.documents.create(url: obj_key, text: filename, doc_type: doc_type)
    new_doc.get_signed_url
  end

  def filename_formatter(options, completing_string="pricings_")
    if options[:mot]
      "#{options[:mot]}_#{completing_string + formated_date}.xlsx"
    else
      "#{completing_string + formated_date}.xlsx"
    end
  end

  def formated_date
    DateTime.now.strftime("%Y-%m-%d")
  end

  def default_aux_hash
    {
      itineraries:   {},
      nexuses:       {},
      vehicle:       {},
      transit_times: {}
    }
  end

  def tenant_finder(tenant_id)
    Tenant.find(tenant_id)
  end

  def itinerary(itinerary_id)
    Itinerary.find(itinerary_id)
  end

  def create_workbook(dir)
    WriteXLSX.new(dir)
  end

  def add_worksheet_to_workbook(workbook, header_text, worksheet_name=nil)
    header_format = workbook.add_format
    header_format.set_bold
    worksheet = if worksheet_name
                  workbook.add_worksheet(worksheet_name)
                else
                  workbook.add_worksheet
                end
    header_text.each_with_index { |hv, i| worksheet.write(0, i, hv, header_format) }
    { worksheet: worksheet, workbook: workbook }
  end

  def write_to_sheet(worksheet, row, start, data)
    data.each do |record|
      worksheet.write(row, start, record)
      start += 1
    end
    worksheet
  end

  def writeable_data(current_itinerary, pricing, current_origin, current_destination, current_transit_time, current_vehicle, key, fee, carrier, range_fee=nil)
    data = [carrier, current_itinerary.mode_of_transport, pricing[:load_type], pricing[:effective_date], pricing[:expiration_date], current_origin.name, current_destination.name, current_transit_time, pricing[:wm_rate], current_vehicle.name, key, fee[:currency], fee[:rate_basis], fee[:min]]
    data << if range_fee
              range_fee[:rate]
            else
              fee[:rate]
            end
    data << fee[:hw_threshold] || ""
    data << fee[:hw_rate_basis] || ""
    data
  end

  def stop(stop)
    Stop.find(stop)
  end
end
