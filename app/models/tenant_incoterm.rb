class TenantIncoterm < ApplicationRecord
  belongs_to :tenant
  belongs_to :incoterm
end
