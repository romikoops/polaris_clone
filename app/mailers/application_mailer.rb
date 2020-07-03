# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@itsmycargo.tech'
  layout 'mailer'

  include ActionView::Helpers::TextHelper

  def scope_for(record:)
    ::OrganizationManager::ScopeService.new(
      target: record,
      organization: current_organization
    ).fetch
  end

  def mail_target_interceptor(billing, email)
    billing == 'external' ? email : Settings.emails.booking
  end

  def set_current_id(organization_id:)
    Organizations.current_id = organization_id
  end

  def current_organization
    @current_organization ||= Organizations::Organization.current
  end

  def default_domain
    current_organization.domains.find_by(default: true)&.domain
  end

  def subject_line(shipment:, type:, references:)
    template = scope_for(record: shipment.user).dig(:email_subject_template)
    liquid = Liquid::Template.parse(template)
    noun = type == :quotation ? 'Quotation' : 'Booking'
    truncate(
      liquid.render(context(shipment: ::Legacy::ShipmentDecorator.new(shipment), references: references, noun: noun)),
      length: 78
    )
  end

  def context(shipment:, references:, noun:)
    {
      imc_reference: shipment.imc_reference,
      external_id: shipment.external_id,
      origin_locode: shipment.origin_locode,
      origin_city: shipment.origin_city,
      origin: shipment.origin,
      destination_locode: shipment.destination_locode,
      destination_city: shipment.destination_city,
      destination: shipment.destination,
      total_weight: shipment.total_weight,
      total_volume: shipment.total_volume,
      client_name: shipment.client_name,
      load_type: shipment.load_type,
      references: truncate("Refs: #{references.join(", ")}", length: 23, separator: ' '),
      routing: shipment.routing,
      noun: noun
    }.deep_stringify_keys
  end
end
