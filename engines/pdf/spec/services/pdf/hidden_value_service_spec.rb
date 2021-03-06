# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pdf::HiddenValueService, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:scope) { FactoryBot.create(:organizations_scope, target: user, content: {}) }
  let(:klass) { described_class.new(user: user) }

  context "with hidden grand totals" do
    before do
      scope.update(content: {hide_grand_total: true})
    end

    it "returns hidden_grand_totals true" do
      expect(klass.hide_total_args[:hidden_grand_total]).to eq(true)
    end
  end

  context "with hidden sub totals" do
    let(:klass) { described_class.new(user: nil) }

    before do
      scope.update(content: {hide_sub_totals: true})
    end

    it "returns hidden sub totals true" do
      expect(klass.hide_total_args[:hidden_sub_total]).to eq(true)
    end
  end

  context "with hidden converted grand totals" do
    before do
      scope.update(content: {hide_converted_grand_total: true})
    end

    it "returns hide_converted_grand_total true" do
      expect(klass.hide_total_args[:hide_converted_grand_total]).to eq(true)
    end
  end

  context "when user is nil" do
    it "returns true for all hidden values" do
      expected_value = {hidden_grand_total: true, hidden_sub_total: true, hide_converted_grand_total: true}
      class_with_nil_user = described_class.new(user: nil)
      expect(class_with_nil_user.hide_total_args).to eq(expected_value)
    end
  end

  context "when user is admin" do
    let(:expected_value) { {hidden_grand_total: false, hidden_sub_total: false, hide_converted_grand_total: false} }

    it "returns true for all hidden values" do
      expect(klass.admin_args).to eq(expected_value)
    end
  end
end
