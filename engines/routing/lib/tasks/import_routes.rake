# frozen_string_literal: true

namespace :routing do
  task import_routes: :environment do
    TMP_PATH = 'tmp/tmp_csv.gz'
    s3 = Aws::S3::Client.new
    bucket = 'assets.itsmycargo.com'
    puts 'Reading from csv...'

    file = s3.get_object(
      bucket: 'assets.itsmycargo.com',
      key: 'data/location_data/freight_results.csv.gz',
      response_content_disposition: 'application/x-gzip'
    ).body.read

    File.open(TMP_PATH, 'wb') { |f| f.write(file) }
    routes = []
    missed_names = []
    blocked = {}
    default_cargo_types = { lcl: false, fcl_reefer: false, fcl: false }
    Zlib::GzipReader.open(TMP_PATH) do |gz|
      csv = CSV.new(gz, headers: true)
      csv.each do |row|
        key = [row['origin'], row['destination'], row['mode_of_transport']].join('-')
        to_sub, time_factor, price_factor = case row['mode_of_transport']
                                            when 'ocean'
                                              [' Port', 8, 2]
                                            when 'air'
                                              [' Airport', 1, 10]
                                            when 'truck'
                                              [' Depot', 7, 7]
                                            when 'rail'
                                              [' Railyard', 10, 4]
                                            else
                                              ['', 1, 10]
                  end
        origin = Routing::Location.find_by(name: row['origin'].gsub(to_sub, ''))
        destination = Routing::Location.find_by(name: row['destination'].gsub(to_sub, ''))

        missed_names << row['origin'] unless origin.present?
        missed_names << row['destination'] unless destination.present?
        next unless origin.present? && destination.present?

        key = [origin.id, destination.id, row['mode_of_transport']].join('-')
        next if blocked[key].present?

        cargo_types = default_cargo_types.dup
        Legacy::Itinerary.where(
          sandbox_id: nil,
          name: [origin.name, destination.name].join(' - '),
          mode_of_transport: row['mode_of_transport']
        ).each do |it|
          next if it.tenant.nil?

          it.pricings.map(&:cargo_class).uniq.each do |cc|
            if cc == 'lcl'
              cargo_types[:lcl] = true
            elsif cc.include?('_rf')
              cargo_types[:fcl_reefer] = true
            else
              cargo_types[:fcl] = true
            end
          end
        end
        route = Routing::Route.find_or_create_by(
          origin_id: origin.id,
          destination_id: destination.id,
          mode_of_transport: row['mode_of_transport'].to_sym
        )

        route&.update(cargo_types)

        blocked[key] = true
      end
    end

    puts missed_names
    File.delete(TMP_PATH) if File.exist?(TMP_PATH)
    ::Legacy::Hub.find_each do |hub|
      
      hub_loc = Routing::Location.find_by(name: hub.nexus.name)
      next unless hub_loc
      
      Routing::Location.where(country_code: hub.address.country.code.downcase).where.not(bounds: nil).each do |trucking_location|
        [
          { origin_id: hub_loc.id, destination_id: trucking_location.id },
          { origin_id: trucking_location.id, destination_id: hub_loc.id }
        ].each do |direction|
          Routing::Route.create({
            mode_of_transport: :truck,
            time_factor: 2,
            price_factor: 4,
            lcl: true,
            fcl: true,
            fcl_reefer: false
          }.merge(direction))
        end
      end
    end
  end
end
