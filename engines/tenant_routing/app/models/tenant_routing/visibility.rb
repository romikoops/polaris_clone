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
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  connection_id :uuid
#  target_id     :uuid
#
# Indexes
#
#  visibility_connection_index  (connection_id)
#  visibility_target_index      (target_type,target_id)
#
