start_zip = 10_000
end_zip = 49_805
zips = []
tmp_zip = start_zip
while tmp_zip <= end_zip
  zips << {zipcode: tmp_zip, country_code: 'SE'}
  tmp_zip += 1
end
TruckingDestination.create!(zips)