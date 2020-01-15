# frozen_string_literal: true

class Tenant < Legacy::Tenant
  include ImageTools

  has_many :shipments, dependent: :destroy
  has_many :nexuses, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :tenant_vehicles, dependent: :destroy
  has_many :vehicles, through: :tenant_vehicles, dependent: :destroy
  has_many :tenant_cargo_item_types, dependent: :destroy
  has_many :cargo_item_types, through: :tenant_cargo_item_types, dependent: :destroy
  has_many :itineraries, dependent: :destroy
  has_many :stops, through: :itineraries, dependent: :destroy
  has_many :trips, through: :itineraries, dependent: :destroy
  has_many :layovers, through: :stops, dependent: :destroy
  has_many :trucking_pricings, dependent: :destroy
  has_many :hub_truckings, through: :hubs, dependent: :destroy
  has_many :trucking_destinations, through: :hub_truckings, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :pricings, dependent: :destroy
  has_many :rates, class_name: 'Pricings::Pricing', dependent: :destroy
  has_many :pricing_exceptions, dependent: :destroy
  has_many :pricing_details, dependent: :destroy
  has_many :local_charges, dependent: :destroy
  has_many :customs_fees, dependent: :destroy
  has_many :tenant_incoterms, dependent: :destroy
  has_many :incoterms, through: :tenant_incoterms, dependent: :destroy
  has_many :seller_incoterm_liabilities, through: :incoterms, dependent: :destroy
  has_many :buyer_incoterm_liabilities, through: :incoterms, dependent: :destroy
  has_many :seller_incoterm_scopes, through: :incoterms, dependent: :destroy
  has_many :buyer_incoterm_scopes, through: :incoterms, dependent: :destroy
  has_many :seller_incoterm_charges, through: :incoterms, dependent: :destroy
  has_many :buyer_incoterm_charges, through: :incoterms, dependent: :destroy
  has_many :max_dimensions_bundles, dependent: :destroy
  has_many :map_data, dependent: :destroy
  has_many :agencies, dependent: :destroy
  has_many :pricing_requests, dependent: :destroy
  has_many :charge_categories

  # validates :scope, presence: true, scope: true
  validates :emails, presence: true, emails: true

  def get_admin
    users.joins(:role).where('roles.name': 'admin').first
  end

  def self.update_hs_codes
    data = get_all_items('hsCodes')
    data.each do |datum|
      code_ref = datum['_id'].slice(0, 2).to_i
      if code_ref >= 28 && code_ref <= 38
        datum['dangerous'] = true
        update_item('hsCodes', { _id: datum['_id'] }, datum)
      end
    end
  end

  def autogenerate_all_schedules(end_date:, sandbox: nil)
    itineraries.where(sandbox: sandbox).each do |itinerary|
      itinerary.default_generate_schedules(end_date: end_date, sandbox: sandbox)
    end
  end

  def max_dimensions
    max_dimensions_bundles.unit.to_max_dimensions_hash
  end

  def max_aggregate_dimensions
    max_dimensions_bundles.aggregate.to_max_dimensions_hash
  end

  private

  def load_type_filter(load_type, mot)
    mot.each_with_object({}) do |(k, v), h|
      h[k] = v.each_with_object({}) { |(_k, _v), _h| _h[_k] = _k != load_type ? false : _v }
    end
  end

  def self.update_web
    web_data = [
      { subdomain: 'greencarrier', cloudfront: 'E1HIJBT7WVXAP3' },
      { subdomain: 'demo', cloudfront: 'E20JU5F52LP1AZ', index: 'index.html' },
      { subdomain: 'nordicconsolidators', cloudfront: 'E3P24SVVXVUTZO' },
      { subdomain: 'isa', cloudfront: 'E33QYEB8CF5AW0' },
      { subdomain: 'integrail', cloudfront: 'E1WJTKUIV6CYP3' },
      { subdomain: 'easyshipping', cloudfront: 'E2VR366CPGNLTC' },
      { subdomain: 'belglobe', cloudfront: 'E42GZPFHU0WZO' },
      { subdomain: 'eimskip', cloudfront: 'E1XPLYJA1HASN3' }
    ]
    web_data.each do |wd|
      t = Tenant.find_by_subdomain(wd[:subdomain])
      t.web = {} unless t.web
      t.web[:sudomain] = wd[:subdomain]
      t.web[:cloudfront] = wd[:cloudfront]
      t.save!
    end
  end

  def mot_scope_attributes(mot)
    mot.reduce({}) do |h, (k, v)|
      h.merge v.each_with_object({}) { |(_k, _v), _h| _h["#{k}_#{_k}"] = _v }
    end
  end

  def create_default_max_dimensions
    MaxDimensionsBundle.create_defaults_for(self)
  end

  def create_default_aggregate_max_dimensions
    MaxDimensionsBundle.create_defaults_for(self, aggregate: true)
  end
end

# == Schema Information
#
# Table name: tenants
#
#  id          :bigint           not null, primary key
#  theme       :jsonb
#  emails      :jsonb
#  subdomain   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  phones      :jsonb
#  addresses   :jsonb
#  name        :string
#  scope       :jsonb
#  currency    :string           default("EUR")
#  web         :jsonb
#  email_links :jsonb
#
