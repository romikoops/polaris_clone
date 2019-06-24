# frozen_string_literal: true

class Currency < Legacy::Currency
end

# == Schema Information
#
# Table name: currencies
#
#  id         :bigint(8)        not null, primary key
#  today      :jsonb
#  yesterday  :jsonb
#  base       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :integer
#
