# frozen_string_literal: true

RSpec.shared_context "journey_result" do
  let(:result_set) { FactoryBot.create(:journey_result_set, query: query, result_count: 0) }
  let(:expiration_date) { 2.weeks.from_now }
  let(:result) {
    FactoryBot.build(:journey_result,
      result_set: result_set,
      expiration_date: expiration_date,
      route_sections: route_sections,
      line_item_sets: [line_item_set])
  }
  let(:route_sections) { [] }
  let(:line_items) { [] }
  let(:line_item_set) { FactoryBot.build(:journey_line_item_set, line_items: line_items) }

  let(:multiple_results) {
    FactoryBot.create_list(:journey_result, 5,
      :empty,
      result_set: result_set,
      expiration_date: expiration_date,
      sections: 0)
  }
end
