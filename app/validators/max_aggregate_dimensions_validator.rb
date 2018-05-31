class MaxAggregateDimensionsValidator < ActiveModel::Validator
  def validate(record)
    dimension_names = CargoItem::MAX_AGGREGATE_DIMENSIONS[:general].keys
    mode_of_transport = record.itinerary && record.itinerary.mode_of_transport.to_sym
 
    max_dimensions =
      CargoItem::MAX_AGGREGATE_DIMENSIONS[mode_of_transport] ||
      CargoItem::MAX_AGGREGATE_DIMENSIONS[:general]
    

  	sums = record.cargo_items.each_with_object(Hash.new(0)) do |cargo_item, return_h|  		
	  	dimension_names.each do |dimension_name|
	  		return_h[dimension_name] += cargo_item[dimension_name] * cargo_item.quantity
	  	end
  	end

    dimension_names.each do |dimension_name|
      max = max_dimensions[dimension_name]
  		if sums[dimension_name] > max && max > 0
  			message = "cannot be greater than #{max}"
      	record.errors["Total #{humanize_dimension(dimension_name)} (#{dimension_name})"] << message
  		end
  	end
  end

  private

  def humanize_dimension(dimension)
  	case dimension
  	when :dimension_x   then 'length'
  	when :dimension_y   then 'width'
  	when :dimension_z   then 'height'
  	when :payload_in_kg then 'weight'
  	end
  end
end