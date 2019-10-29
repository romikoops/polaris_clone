# frozen_string_literal: true

require 'spec_helper'
require 'database_cleaner'

RSpec.configure do |c|
  c.use_transactional_examples = false

  c.after :each do
    DatabaseCleaner.clean_with(:deletion, only: %w(sequential_sequences))
  end
end
