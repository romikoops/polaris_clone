# frozen_string_literal: true

module Journey
  class Offer < ApplicationRecord
    has_many :offer_line_item_sets, inverse_of: :offer
    has_many :line_item_sets, through: :offer_line_item_sets
    has_many :results, through: :line_item_sets
    belongs_to :query, inverse_of: :offers
    has_one_attached :file

    validates_presence_of :offer_line_item_sets

    def attachment
      file&.download
    end

    def xlsx
      ExcelWriterService.new(offer: offer).quotation_sheet
    end
  end
end

# == Schema Information
#
# Table name: journey_offers
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  query_id   :uuid
#
# Indexes
#
#  index_journey_offers_on_query_id  (query_id)
#
# Foreign Keys
#
#  fk_rails_...  (query_id => journey_queries.id)
#
