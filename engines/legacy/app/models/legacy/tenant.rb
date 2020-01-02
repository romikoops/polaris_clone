# frozen_string_literal: true

module Legacy
  class Tenant < ApplicationRecord
    self.table_name = 'tenants'

    has_many :users
    has_many :shipments
    has_many :itineraries, class_name: 'Legacy::Itinerary'
    has_many :hubs, dependent: :destroy

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
