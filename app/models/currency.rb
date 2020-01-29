# frozen_string_literal: true

class Currency < Legacy::Currency
end

# == Schema Information
#
# Table name: currencies
#
#  id         :bigint           not null, primary key
#  base       :string
#  today      :jsonb
#  yesterday  :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :integer
#
# Indexes
#
#  index_currencies_on_tenant_id  (tenant_id)
#
