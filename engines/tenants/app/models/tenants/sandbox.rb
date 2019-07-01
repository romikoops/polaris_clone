module Tenants
  class Sandbox < ApplicationRecord
  end
end

# == Schema Information
#
# Table name: tenants_sandboxes
#
#  id         :uuid             not null, primary key
#  tenant_id  :uuid
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
