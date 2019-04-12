# frozen_string_literal: true

if ENV['CI_NODE_TOTAL'] || ENV['KNAPSACK_GENERATE_REPORT']
  require 'knapsack'

  # CUSTOM_CONFIG_GOES_HERE

  Knapsack::Adapters::CucumberAdapter.bind
end
