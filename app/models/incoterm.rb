class Incoterm < ApplicationRecord
  belongs_to :seller_incoterm_liability, class_name: "IncotermLiability"
  belongs_to :buyer_incoterm_liability, class_name: "IncotermLiability"
  belongs_to :seller_incoterm_scope, class_name: "IncotermScope"
  belongs_to :buyer_incoterm_scope, class_name: "IncotermScope"
  belongs_to :seller_incoterm_charge, class_name: "IncotermCharge"
  belongs_to :buyer_incoterm_charge, class_name: "IncotermCharge"
  has_many :tenant_incoterms
end
