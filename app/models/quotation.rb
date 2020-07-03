# frozen_string_literal: true

class Quotation < Legacy::Quotation
end

# == Schema Information
#
# Table name: quotations
#
#  id                   :bigint           not null, primary key
#  billing              :integer          default("external")
#  name                 :string
#  target_email         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  distinct_id          :uuid
#  legacy_user_id       :integer
#  original_shipment_id :integer
#  sandbox_id           :uuid
#  user_id              :uuid
#
# Indexes
#
#  index_quotations_on_sandbox_id  (sandbox_id)
#  index_quotations_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users_users.id)
#
