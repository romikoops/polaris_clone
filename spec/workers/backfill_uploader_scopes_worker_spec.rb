# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillUploaderScopesWorker, type: :worker do
  let!(:scope) do
    FactoryBot.create(:organizations_scope, content: { v2_uploaders: { pricings: true, saco_pricings: false } })
  end

  describe "#perform" do
    before { described_class.new.perform }

    it "updates the uploaders hash in the Scope" do
      expect(scope.reload.content["uploader"]).to eq({ "pricings" => "v3", "saco_pricings" => "legacy" })
    end
  end
end
