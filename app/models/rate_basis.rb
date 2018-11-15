class RateBasis < ApplicationRecord

  def self.get_internal_key(external_rate_basis)
    rate_basis = RateBasis.find_by(external_code: external_rate_basis)
    
    return rate_basis.nil? ? external_rate_basis : rate_basis.internal_code

  end
end
