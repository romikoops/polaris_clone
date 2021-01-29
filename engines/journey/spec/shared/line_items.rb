# frozen_string_literal: true

RSpec.shared_context "journey_line_items" do
  let(:pre_carriage_line_items_with_cargo) do
    cargo_line_items_for_section(section: pre_carriage_section)
  end

  let(:pre_carriage_line_item_per_shipment) do
    FactoryBot.build(:journey_line_item,
      route_section: pre_carriage_section)
  end

  let(:origin_transfer_line_items_with_cargo) do
    cargo_line_items_for_section(section: origin_transfer_section)
  end

  let(:origin_transfer_line_item_per_shipment) do
    FactoryBot.build(:journey_line_item,
      route_section: origin_transfer_section)
  end

  let(:freight_line_items_with_cargo) do
    cargo_line_items_for_section(section: freight_section)
  end

  let(:freight_line_item_per_shipment) do
    FactoryBot.build(:journey_line_item,
      route_section: freight_section)
  end

  let(:destination_transfer_line_items_with_cargo) do
    cargo_line_items_for_section(section: destination_transfer_section)
  end

  let(:destination_transfer_line_item_per_shipment) do
    FactoryBot.build(:journey_line_item,
      route_section: destination_transfer_section)
  end

  let(:on_carriage_line_items_with_cargo) do
    cargo_line_items_for_section(section: on_carriage_section)
  end

  let(:on_carriage_line_item_per_shipment) do
    FactoryBot.build(:journey_line_item,
      route_section: on_carriage_section)
  end

  def cargo_line_items_for_section(section:)
    cargo_units.map do |cargo_unit|
      FactoryBot.build(:journey_line_item,
        cargo_units: [cargo_unit],
        route_section: section)
    end
  end
end
