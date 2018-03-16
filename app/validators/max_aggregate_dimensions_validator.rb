class MaxAggregateDimensionsValidator < ActiveModel::Validator
  def validate(record)
  	dimensions = CargoItem::MAX_DIMENSIONS.keys

  	sums = record.cargo_items.each_with_object(Hash.new(0)) do |cargo_item, return_h|  		
	  	dimensions.each do |dimension|
	  		return_h[dimension] += cargo_item[dimension]
	  	end
  	end

  	dimensions.each do |dimension|
  		if sums[dimension] > (max = CargoItem::MAX_DIMENSIONS[dimension])
  			message = "Total #{humanize_dimension(dimension)} (#{dimension}) cannot be > #{max}"
      	record.errors[dimension] << message
  		end
  	end
  end

  private

  def humanize_dimension(dimension)
  	case dimension
  	when :dimension_x then 'length'
  	when :dimension_y then 'width'
  	when :dimension_z then 'height'
  	when :payload_in_kg then 'weight'
  	end
  end
end