# frozen_string_literal: true

namespace :currencies do
  task update: :environment do
    Money.default_bank.update_rates
  end
end
