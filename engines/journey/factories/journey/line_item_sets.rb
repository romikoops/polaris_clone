# frozen_string_literal: true
FactoryBot.define do
  factory :journey_line_item_set, class: "Journey::LineItemSet" do
    association :result, factory: :journey_result
    transient do
      line_item_count { 1 }
    end

    line_items do
      instance.result.route_sections.flat_map do |route_section|
        Array.new(line_item_count) do
          association :journey_line_item, route_section: route_section, line_item_set: instance
        end
      end
    end
  end
end
