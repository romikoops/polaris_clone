class GooglePlaces
  BASE_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
  API_KEY = ENV["GOOGLE_MAPS_SERVER_API_KEY"]
  def get_place_name(lat_lng, name)
    req_url = "#{BASE_URL}location=#{lat_lng}&rankby=distance&name=#{name}&key=#{API_KEY}"
  end
end