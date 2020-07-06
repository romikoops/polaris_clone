# frozen_string_literal: true

class NotesController < ApplicationController
  skip_before_action :doorkeeper_authorize!

  def index
    itineraries = Legacy::Itinerary.where(id: params[:itineraries])
    pricings = Pricings::Pricing.where(itinerary_id: params[:itineraries])
    note_association = Legacy::Note.where(organization: current_organization)
    raw_notes = note_association.where(target: itineraries)
                            .or(note_association.where(pricings_pricing_id: pricings.ids))
    transformed_notes = raw_notes.map { |note| Api::V1::NoteDecorator.new(note).legacy_json }
                                 .uniq { |note| note.slice('header', 'body', 'service') }

    response_handler(transformed_notes)
  end

  def delete
    itinerary = current_organization.itineraries.find_by(id: params[:itinerary_id], sandbox: @sandbox)
    note = itinerary.notes.find_by(id: params[:id], sandbox: @sandbox)
    note.destroy
    resp = itinerary.notes.where(sandbox: @sandbox)
    response_handler(resp)
  end
end
