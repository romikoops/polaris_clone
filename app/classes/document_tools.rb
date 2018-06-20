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
end
