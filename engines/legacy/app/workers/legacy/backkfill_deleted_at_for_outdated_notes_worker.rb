# frozen_string_literal: true

module Legacy
  class BackkfillDeletedAtForOutdatedNotesWorker
    include Sidekiq::Worker

    def perform
      Pricings::Pricing.where(id: Legacy::Note.select(:pricings_pricing_id)).find_each do |pricing|
        pricing_notes = Legacy::Note.where(pricings_pricing_id: pricing.id)
        pricing_notes.find_each do |note|
          outdated_notes = pricing_notes.where(header: note.header).order("updated_at DESC")[1..]
          next if outdated_notes.blank?

          outdated_notes.each(&:destroy)
        end
      end
    end
  end
end
