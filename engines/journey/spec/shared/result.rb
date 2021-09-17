# frozen_string_literal: true

RSpec.shared_context "journey_result" do
  let(:expiration_date) { 2.weeks.from_now }
  let(:result) do
    FactoryBot.build(:journey_result,
      query: query,
      expiration_date: expiration_date,
      route_sections: route_sections,
      line_item_sets: [line_item_set])
  end
  let(:route_sections) { [] }
  let(:line_items) { [] }
  let(:line_item_set) { FactoryBot.build(:journey_line_item_set, line_items: line_items) }

  let(:multiple_results) do
    FactoryBot.create_list(:journey_result, 5,
      :empty,
      query: query,
      expiration_date: expiration_date,
      sections: 0)
  end
end
