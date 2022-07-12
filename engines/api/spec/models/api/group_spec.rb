# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Group, type: :model do
  let(:group_a) { FactoryBot.create(:groups_group, name: "a_group") }
  let(:group_c) { FactoryBot.create(:groups_group, name: "c_group") }

  before do
    group_a
    group_c
  end

  describe "with sorting" do
    let(:sort_by) { "#{sort_key}_#{direction_key}" }
    let(:sorted_group) { described_class.sorted_by(sort_by) }

    context "when sorting groups by name" do
      let(:sort_key) { "name" }

      context "when sorting in ascending order" do
        let(:direction_key) { "asc" }

        it "returns groups with name in ascending order" do
          expect(sorted_group.ids).to eq([group_a.id, group_c.id])
        end
      end

      context "when sorting in descending order" do
        let(:direction_key) { "desc" }

        it "returns groups with name in descending order" do
          expect(sorted_group.ids).to eq([group_c.id, group_a.id])
        end
      end
    end

    context "with invalid sort option" do
      let(:sort_key) { "crypto_coins" }
      let(:direction_key) { "asc" }

      it "raises error with invalid sort option" do
        expect { sorted_group.ids }.to raise_error(ArgumentError)
      end
    end
  end

  describe "with filtering" do
    let(:sort_by) { "#{sort_key}_#{direction_key}" }
    let(:sorted_group) { described_class.sorted_by(sort_by) }

    context "when filtering groups by name" do
      let(:filter_name_search) { described_class.name_search("c_group") }

      it "returns groups with name `c_group`" do
        expect(filter_name_search.ids).to eq([group_c.id])
      end
    end
  end
end
