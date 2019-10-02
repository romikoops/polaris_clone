# frozen_string_literal: true

class Incoterm < ApplicationRecord
  belongs_to :seller_incoterm_liability, class_name: 'IncotermLiability'
  belongs_to :buyer_incoterm_liability, class_name: 'IncotermLiability'
  belongs_to :seller_incoterm_scope, class_name: 'IncotermScope'
  belongs_to :buyer_incoterm_scope, class_name: 'IncotermScope'
  belongs_to :seller_incoterm_charge, class_name: 'IncotermCharge'
  belongs_to :buyer_incoterm_charge, class_name: 'IncotermCharge'
  has_many :tenant_incoterms
end

# == Schema Information
#
# Table name: incoterms
#
#  id                           :bigint           not null, primary key
#  code                         :string
#  description                  :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  seller_incoterm_scope_id     :integer
#  seller_incoterm_liability_id :integer
#  seller_incoterm_charge_id    :integer
#  buyer_incoterm_scope_id      :integer
#  buyer_incoterm_liability_id  :integer
#  buyer_incoterm_charge_id     :integer
#
