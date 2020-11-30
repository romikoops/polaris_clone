# frozen_string_literal: true

require "rails_helper"

RSpec.describe Migrator do
  before { FactoryBot.create(:locations_location) }

  it "runs migrators" do
    Migrator.run
  end
end
