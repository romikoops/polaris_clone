# frozen_string_literal: true

require "rails_helper"

class TestUpsertable
  UUID_V5_NAMESPACE = "82badd06-a9bc-495f-a02e-87ab924d1bfb"
  UUID_KEYS = %i[a b c].freeze
  attr_reader :a, :b, :c

  include Legacy::Upsertable

  @a = "a"
  @b = "b"
  @c = "c"
end

RSpec.describe Legacy::Upsertable do
  describe ".upsertable_id" do
    it "generates a UUID based on the values", :aggregate_failures do
      uuid = TestUpsertable.new.upsertable_id
      expect(uuid).to be_a(UUIDTools::UUID)
      expect(uuid.to_s).to eq("427cb0df-888b-54dc-adaf-39f725135d31")
    end
  end
end
