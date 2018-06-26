# frozen_string_literal: true

require "#{Rails.root}/db/seed_classes/tenant_seeder.rb"

TenantSeeder.perform
