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
