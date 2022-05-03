# frozen_string_literal: true

class BackfillDoorkeeperApplicationsOnDomainsWorker
  include Sidekiq::Worker

  SIREN_DOMAINS = %w[
    7con.itsmycargo.shop
    beta-berger.itsmycargo.shop
    beta-demo.itsmycargo.shop
    beta-fivestar.itsmycargo.shop
    beta-gateway.itsmycargo.shop
    beta-pcs.itsmycargo.shop
    beta-pet.itsmycargo.shop
    beta-saco.itsmycargo.shop
    beta-sacoargentina.itsmycargo.shop
    beta-sacolcl.itsmycargo.shop
    beta-ssc.itsmycargo.shop
    unsworth.itsmycargo.shop
    beta.itsmycargo.shop
    petlogistics.itsmycargo.shop
    sacoargentina.itsmycargo.shop
    siren-%.itsmycargo.shop
    siren-%.lvh.me
    siren-sir-390.itsmycargo.dev
  ].freeze
  BRIDGE_DOMAINS = %w[
    control.itsmycargo.com
    control.itsmycargo.shop
  ].freeze

  def perform
    dipper_application = Doorkeeper::Application.find_by(name: "dipper")
    bridge_application = Doorkeeper::Application.find_by(name: "bridge")
    siren_application = Doorkeeper::Application.find_by(name: "siren")

    Organizations::Domain.where(domain: SIREN_DOMAINS).each do |domain|
      domain.update(application_id: siren_application.id)
    end
    Organizations::Domain.where(domain: BRIDGE_DOMAINS).each do |domain|
      domain.update(application_id: bridge_application.id)
    end
    Organizations::Domain.where.not(domain: SIREN_DOMAINS + BRIDGE_DOMAINS).each do |domain|
      domain.update(application_id: dipper_application.id)
    end
  end
end
