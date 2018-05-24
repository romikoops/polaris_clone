class AggregatedCargo < ApplicationRecord
	belongs_to :shipment

	def set_chargeable_weight!(mot = "ocean")
	  self.chargeable_weight =
	    [volume * CargoItem::EFFECTIVE_TONNAGE_PER_CUBIC_METER[mot.to_sym] * 1000, weight].max
	  
	  save!
	end

	def dangerous_goods?
		false
	end
end
