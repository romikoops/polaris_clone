class TrainPricing < ActiveRecord::Base
  # Class methods
  def self.all_pricings_by_locations
    starthub_names = self.all.pluck(:starthub_name)
    endhub_names = self.all.pluck(:endhub_name)
    hub_combinations = starthub_names.zip(endhub_names).uniq

    pricings_by_locations = []
    hub_combinations.each do |hubs|
      pricing_row = self.where("starthub_name = ? AND endhub_name = ?", hubs[0], hubs[1]).pluck(:price)
      pricings_by_locations << { hubs => pricing_row }
    end
    pricings_by_locations
  end
end
