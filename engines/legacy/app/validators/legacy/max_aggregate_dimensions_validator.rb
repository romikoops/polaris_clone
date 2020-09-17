# frozen_string_literal: true

module Legacy
  class MaxAggregateDimensionsValidator < ActiveModel::Validator
    def validate(record)
      return true if record.fcl?

      dimension_names = Legacy::CargoItem::DIMENSIONS.dup
      mode_of_transport = record.itinerary&.mode_of_transport&.to_sym

      # If an itinerary has not yet been set, the chargeable weight validation is skipped,
      # since the mode_of_transport is still not known
      dimension_names.delete(:chargeable_weight) if mode_of_transport.nil?
      max_aggregate_dimensions = MaxDimensionsBundle.where(organization_id: record.organization, aggregate: true).to_max_dimensions_hash
      return true if max_aggregate_dimensions.blank?
      max_dimensions =
        max_aggregate_dimensions[mode_of_transport] ||
        max_aggregate_dimensions[:general]
      return true if max_dimensions.blank?

      sums = if record.aggregated_cargo.present?
               obj = { payload_in_kg: record.aggregated_cargo.weight }
               obj[:chargeable_weight] = (record.aggregated_cargo.chargeable_weight ||
                record.aggregated_cargo.calc_chargeable_weight(mode_of_transport)) if mode_of_transport.present?
               obj
             else
               record.cargo_items.each_with_object(Hash.new(0)) do |cargo_item, return_h|
                 dimension_names.each do |dimension_name|
                   value = cargo_item.send(dimension_name)
                   if dimension_name == :chargeable_weight
                     value ||= cargo_item.calc_chargeable_weight(mode_of_transport)
                   end
                   return_h[dimension_name] += value * cargo_item.quantity
                 end
               end
             end
      dimension_names.each do |dimension_name|
        max = max_dimensions[dimension_name]
        next unless sums[dimension_name].present? && sums[dimension_name] > max && max.positive?

        message = "cannot be greater than #{max}"
        error_key = "Total #{humanized_dimension_name(dimension_name)} (#{dimension_name})"
        record.errors[error_key] << message
      end
    end

    private

    def humanized_dimension_name(dimension_name)
      case dimension_name
      when :payload_in_kg then 'weight'
      else dimension_name.to_s
      end
    end
  end
end
