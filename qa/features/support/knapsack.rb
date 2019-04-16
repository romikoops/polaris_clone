# frozen_string_literal: true

if ENV['CI_NODE_TOTAL'] || ENV['KNAPSACK_GENERATE_REPORT']
  require 'knapsack'

  Knapsack::Adapters::CucumberAdapter.bind
end
