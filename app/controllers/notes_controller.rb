# frozen_string_literal: true

class NotesController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def get_notes
    notes = []
    origins = params[:origins] || []
    destinations = params[:destinations] || []
    itineraries = params[:itineraries]
    itineraries.each do |itin|
      next unless origins.include?(itin['originNexusId']) && destinations.include?(itin['destinationNexusId'])
      itinerary = Itinerary.find(itin['id'])
      itinerary.notes.each do |note|
        notes.push(transform_note(itinerary, note))
      end
    end
    response_handler(notes)
  end

  private

  def transform_note(itinerary, note)
    return unless note
    nt = note.as_json
    nt['itineraryTitle'] = itinerary.name
    nt['mode_of_transport'] = itinerary.mode_of_transport
    nt
  end
end
