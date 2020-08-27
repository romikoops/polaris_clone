# frozen_string_literal: true

require "rails_helper"

RSpec.describe Migrator do
  it "runs migrators" do
    Migrator.run
  end
end
