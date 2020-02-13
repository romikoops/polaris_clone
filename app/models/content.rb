# frozen_string_literal: true

class Content < ApplicationRecord
end

# == Schema Information
#
# Table name: contents
#
#  id         :bigint           not null, primary key
#  component  :string
#  index      :integer
#  section    :string
#  text       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :integer
#
# Indexes
#
#  index_contents_on_tenant_id  (tenant_id)
#
