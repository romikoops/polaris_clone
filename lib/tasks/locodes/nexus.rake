# frozen_string_literal: true

namespace :locodes do
  task nexus: :environment do
    Nexus.where(locode: nil).find_each do |nex|
      loc = Locations::Name.find_by(locode: nil, name: nex.name, country_code: nex.country&.code)
      next if loc.nil?

      nex.update(locode: loc.name)
    end
  end
end
