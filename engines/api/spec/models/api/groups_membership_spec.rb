# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::GroupsMembership, type: :model do
  let(:group_default) { FactoryBot.create(:groups_group, name: "default_group") }
  let(:group_demo) { FactoryBot.create(:groups_group, name: "demo_group") }

  let(:company) { FactoryBot.create(:companies_company) }

  let(:group_membership_default) { described_class.create(group: group_default, member: company) }
  let(:group_membership_demo) { described_class.create(group: group_demo, member: company) }

  before do
    group_membership_default
    group_membership_demo
  end

  describe "with sorting" do
    let(:sort_by) { "#{sort_key}_#{direction_key}" }
    let(:sorted_group) { described_class.sorted_by(sort_by) }

    context "when sorting groups by name" do
      let(:sort_key) { "name" }

      context "when sorting in ascending order" do
        let(:direction_key) { "asc" }

        it "returns groups membership with name in ascending order" do
          expect(sorted_group.ids).to eq([group_membership_default.id, group_membership_demo.id])
        end
      end

      context "when sorting in descending order" do
        let(:direction_key) { "desc" }

        it "returns groups membership with name in descending order" do
          expect(sorted_group.ids).to eq([group_membership_demo.id, group_membership_default.id])
        end
      end
    end

    context "when sorting groups by priority" do
      let(:sort_key) { "priority" }

      context "when sorting in ascending order" do
        let(:direction_key) { "asc" }

        it "returns groups membership with priority in ascending order" do
          expect(sorted_group.ids).to eq([group_membership_default.id, group_membership_demo.id])
        end
      end

      context "when sorting in descending order" do
        let(:direction_key) { "desc" }

        it "returns groups membership with priority in descending order" do
          expect(sorted_group.ids).to eq([group_membership_demo.id, group_membership_default.id])
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
  end

  describe "with filtering" do
    let(:sort_by) { "#{sort_key}_#{direction_key}" }
    let(:sorted_group) { described_class.sorted_by(sort_by) }

    context "when filtering groups membership by name" do
      let(:filter_name_search) { described_class.name_search("demo") }

      it "returns groups membership with name `demo_group`" do
        expect(filter_name_search.ids).to eq([group_membership_demo.id])
      end
    end
  end
end
