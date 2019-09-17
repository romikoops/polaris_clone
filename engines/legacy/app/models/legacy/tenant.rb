# frozen_string_literal: true

module Legacy
  class Tenant < ApplicationRecord
    self.table_name = 'tenants'

    has_many :users
    has_many :shipments
    has_many :itineraries, class_name: 'Legacy::Itinerary'

    has_many :margins, as: :applicable
    has_many :rates, class_name: 'Pricings::Pricing', dependent: :destroy

    has_paper_trail

    def subdomain
      super
    end
    deprecate :subdomain, deprecator: ActiveSupport::Deprecation.new('', Rails.application.railtie_name)

    def __subdomain
      self['subdomain']
    end

    def scope_for(user:)
      ::Tenants::ScopeService.new(target: user).fetch
    end

    def tenants_scope
      Tenants::Scope.find_by(target: Tenants::Tenant.find_by(legacy_id: id))&.content || {}
    end
  end
end

# == Schema Information
#
# Table name: tenants
#
#  id          :bigint(8)        not null, primary key
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
