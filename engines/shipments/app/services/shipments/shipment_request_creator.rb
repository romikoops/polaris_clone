# frozen_string_literal: true

module Shipments
  class ShipmentRequestCreator
    attr_reader :shipment_request, :legacy_shipment, :organization, :user, :errors

    def initialize(legacy_shipment:, user:)
      @legacy_shipment = legacy_shipment
      @user = user
      @shipment_request = nil
      @errors = []
    end

    def create
      build_shipment_request
      build_documents
      build_contacts

      @errors << @shipment_request.errors unless @shipment_request.save

      self
    end

    private

    def build_shipment_request
      @organization = Organizations::Organization.find(legacy_shipment.organization_id)
      @shipment_request = ShipmentRequest.new(
        tender_id: legacy_shipment.tender_id,
        billing: legacy_shipment.billing,
        organization_id: organization.id,
        eta: legacy_shipment.planned_eta,
        etd: legacy_shipment.planned_etd,
        cargo_notes: legacy_shipment.cargo_notes,
        notes: legacy_shipment.notes,
        incoterm_text: legacy_shipment.incoterm_text,
        eori: legacy_shipment.eori,
        ref_number: legacy_shipment.imc_reference,
        submitted_at: Time.current,
        user: @user
      )
    end

    def build_documents
      @shipment_request.documents = ::Legacy::File.where(shipment: legacy_shipment).map do |doc|
        Document.new(attachable: shipment_request).tap do |new_doc|
          new_doc.file.attach(doc.file.blob)
        end
      end
    end

    def build_contacts
      build_contact(legacy_type: "shipper", contact_type: "Consignor")
      build_contact(legacy_type: "consignee", contact_type: "Consignee")
      build_notifyees
    end

    def build_contact(legacy_type:, contact_type:)
      legacy_shipment_contact = legacy_shipment.shipment_contacts.find_by(contact_type: legacy_type)

      shipment_request_contact = ShipmentRequestContact.find_or_initialize_by(
        contact: addressbook_contact(legacy_shipment_contact: legacy_shipment_contact),
        shipment_request: shipment_request,
        type: "Shipments::ShipmentRequestContacts::#{contact_type}"
      )

      case contact_type
      when "Consignor"
        @shipment_request.consignor = shipment_request_contact
      when "Consignee"
        @shipment_request.consignee = shipment_request_contact
      end
    end

    def build_notifyees
      legacy_shipment.shipment_contacts.where(contact_type: "notifyee").find_each do |legacy_shipment_contact|
        shipment_request_contact = ShipmentRequestContact.find_or_initialize_by(
          contact: addressbook_contact(legacy_shipment_contact: legacy_shipment_contact),
          shipment_request: shipment_request,
          type: "Shipments::ShipmentRequestContacts::Notifyee"
        )

        @shipment_request.notifyees << shipment_request_contact
      end
    end

    def addressbook_contact(legacy_shipment_contact:)
      legacy_contact = legacy_shipment_contact.contact
      address = legacy_contact.address
      user = Users::Client.unscoped.find(legacy_contact.user_id)
      legacy_contact_attrs = legacy_contact.attributes
        .merge(address.attributes)
        .symbolize_keys
        .slice(
          :city, :company_name, :email, :first_name, :geocoded_address, :last_name,
          :phone, :premise, :province, :street, :street_number
        )

      addressbook_contact = AddressBook::Contact.find_or_initialize_by(
        legacy_contact_attrs.slice(:first_name, :last_name, :email, :phone)
        .merge(
          user: user
        )
      )

      addressbook_contact.update(
        legacy_contact_attrs
        .merge(
          postal_code: address.zip_code,
          user_id: user.id,
          country_code: address.country&.code || ""
        )
      )

      addressbook_contact
    end
  end
end
