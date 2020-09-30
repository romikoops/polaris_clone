# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@itsmycargo.tech'
  layout 'mailer'
  CHARACTER_COUNT = 90

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

  def subject_line(type:, references:, quotation:)
    template = scope_for(record: quotation.user).dig(:email_subject_template)
    liquid = Liquid::Template.parse(template)
    noun = type == :quotation ? 'Quotation' : 'Booking'
    liquid_string = liquid.render(
      context(
        references: references,
        noun: noun,
        quotation: quotation
      )
    )
    grapheme_clusters = liquid_string.each_grapheme_cluster
    return liquid_string if grapheme_clusters.count < CHARACTER_COUNT

    grapheme_clusters.take(CHARACTER_COUNT).join + '...'
  end

  def context(references:, noun:, quotation:)
    {
      imc_reference: quotation.imc_reference,
      external_id: quotation.external_id,
      origin_locode: quotation.origin_locode,
      origin_city: quotation.origin_city,
      origin: quotation.origin,
      destination_locode: quotation.destination_locode,
      destination_city: quotation.destination_city,
      destination: quotation.destination,
      total_weight: quotation.total_weight,
      total_volume: quotation.total_volume,
      client_name: quotation.client_name,
      load_type: quotation.load_type,
      references: truncate("Refs: #{references.join(", ")}", length: 23, separator: ' '),
      routing: quotation.routing,
      noun: noun
    }.deep_stringify_keys
  end
end
