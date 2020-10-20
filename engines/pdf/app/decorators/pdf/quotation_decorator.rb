# frozen_string_literal: true

module Pdf
  class QuotationDecorator < ApplicationDecorator
    delegate_all

    delegate :planned_delivery_date, :planned_pickup_date, :consignee, :notifyees,
      :incoterm_text, :cargo_notes, :notes, :eori, :shipper, to: :shipment

    def remarks
      @remarks ||= Legacy::Remark.where(organization: organization).order(order: :asc)
    end

    def scope_notes
      @scope_notes ||= scope["quote_notes"] || []
    end

    def content
      @content ||= Legacy::Content.get_component("QuotePdf", organization_id)
    end

    def user_profile
      @user_profile ||= Profiles::ProfileService.fetch(user_id: user_id)
    end

    def company
      Companies::Company.joins(:memberships)
        .find_by(organization: organization,
                 companies_memberships: {
                   member_id: user_id,
                   member_type: "Users::User"
                 })
    end

    def shipment
      @shipment ||= Legacy::Shipment.with_deleted.find_by(id: legacy_shipment_id)
    end

    def note_remarks
      @note_remarks ||= tenders.reduce(Legacy::Note.none) { |notes, tender|
        notes.or(Notes::Service.new(tender: tender, remarks: true).fetch)
      }.uniq.pluck(:body)
    end
  end
end
