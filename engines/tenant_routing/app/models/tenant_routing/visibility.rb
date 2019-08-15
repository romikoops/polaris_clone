# frozen_string_literal: true

module TenantRouting
  class Visibility < ApplicationRecord
    belongs_to :target, polymorphic: true
    belongs_to :connection, class_name: 'TenantRouting::Connection'
  end
end

# == Schema Information
#
# Table name: tenant_routing_visibilities
#
#  id            :uuid             not null, primary key
#  target_type   :string
#  target_id     :uuid
#  connection_id :uuid
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
