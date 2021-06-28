# frozen_string_literal: true

FactoryBot.define do
  factory :hubs_frame, class: "Rover::DataFrame" do
    transient do
      hub_traits { %i[hamburg shanghai felixstowe gothenburg] }
      hubs { hub_traits.map { |trait| FactoryBot.build(:legacy_hub, trait) } }
    end
    initialize_with do
      data = hubs.map do |hub|
        {
          "status" => hub.hub_status,
          "type" => hub.hub_type,
          "name" => hub.name,
          "locode" => hub.hub_code,
          "terminal" => hub.terminal,
          "terminal_code" => hub.terminal_code,
          "latitude" => hub.latitude,
          "longitude" => hub.longitude,
          "country" => hub.address.country.name,
          "full_address" => hub.address.geocoded_address,
          "free_out" => hub.free_out,
          "import_charges" => hub.mandatory_charge.import_charges,
          "export_charges" => hub.mandatory_charge.export_charges,
          "pre_carriage" => hub.mandatory_charge.pre_carriage,
          "on_carriage" => hub.mandatory_charge.on_carriage,
          "alternative_names" => ""
        }
      end

      new(data, types: ExcelDataServices::DataFrames::DataProviders::Hubs::Hubs.column_types)
    end
  end
end
