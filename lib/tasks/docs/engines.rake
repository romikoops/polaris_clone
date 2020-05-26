# frozen_string_literal: true

require_relative "../../cobra_helper"

namespace :docs do
  desc "Update Engines Documentation"
  task engines: :environment do
    CobraHelper.graphviz
  end
end
