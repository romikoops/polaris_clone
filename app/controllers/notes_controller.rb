# frozen_string_literal: true

class NotesController < ApplicationController
  skip_before_action :require_authentication!
  skip_before_action :require_non_guest_authentication!

  def get_notes
    itineraries = Itinerary.where(id: params[:itineraries])
    pricings = Pricings::Pricing.where(itinerary_id: params[:itineraries])
    legacy_pricings = Legacy::Pricing.where(itinerary_id: params[:itineraries])
    raw_notes = Note.where(target: itineraries | pricings | legacy_pricings).uniq { |note| note.slice(:header, :body) }

    response_handler(raw_notes.map { |note| transform_note(note) })
  end

  def delete
    itinerary = current_tenant.itineraries.find_by(id: params[:itinerary_id], sandbox: @sandbox)
    note = itinerary.notes.find_by(id: params[:id], sandbox: @sandbox)
    note.destroy
    resp = itinerary.notes.where(sandbox: @sandbox)
    response_handler(resp)
  end

  private

  def transform_note(note)
    return unless note

    nt = note.as_json
    nt['itineraryTitle'] = note.target.name if note.target_type.include?('Itinerary')
    nt['itineraryTitle'] = note.target.itinerary.name if note.target_type.include?('Pricing')
    nt['mode_of_transport'] = note.target.mode_of_transport if note.target_type.include?('Itinerary')
    nt['mode_of_transport'] = note.target.itinerary.mode_of_transport if note.target_type.include?('Pricing')
    nt['service'] = note.target.tenant_vehicle.full_name if note.target_type.include?('Pricing')
    nt
  end
end
