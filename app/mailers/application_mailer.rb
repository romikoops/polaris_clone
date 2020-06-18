# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@itsmycargo.tech'
  layout 'mailer'

  include ActionView::Helpers::TextHelper

  def scope_for(record:, sandbox: nil)
    ::Tenants::ScopeService.new(
      target: ::Tenants::User.find_by(legacy_id: record.id),
      tenant: ::Tenants::Tenant.find_by(legacy_id: record.tenant_id),
      sandbox: sandbox
    ).fetch
  end

  def mail_target_interceptor(user, email)
    if user.internal?
      Settings.emails.booking
    else
      email
    end
  end

  def subject_line(shipment:, type:, references:)
    noun = type == :quotation ? 'Quotation' : 'Booking'
    [
      "#{shipment.lcl? ? "LCL" : "FCL"} #{noun}:",
      "#{shipment.origin_nexus.name} - #{shipment.destination_nexus.name},",
      truncate("Refs: #{references.join(", ")}", length: 23, separator: ' ')
    ].join(' ')
  end
end
