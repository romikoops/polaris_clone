geometry_hash = Hash.from_xml(File.open('db/dummydata/china.kml'))
geometries = h['kml']['Document']['Folder']['Placemark']
new_geometries = []
geometries.each do |geo|
  new_geo = Geometry.new()
  names = geo['ExtendedData']['SimpleData']
  names.each_with_index do |name, i|
    key = "name_#{i +1}"
    new_geo[key] = name
  end
end