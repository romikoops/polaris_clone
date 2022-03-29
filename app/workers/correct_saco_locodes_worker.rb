# frozen_string_literal: true

class CorrectSacoLocodesWorker
  include Sidekiq::Worker

  VALID_TO_INVALID_MAP = {
    "KWSWK" => "KWKWI",
    "SAJBI" => "SAJUB",
    "USBAL" => "USBTM",
    "USHOU" => "USH5S",
    "USJAX" => "USJAV",
    "USLGB" => "USLB3",
    "USLAX" => "USLSQ",
    "USMIA" => "USMII",
    "USMES" => "USIPS",
    "USORF" => "USNFF",
    "USPHL" => "USPDP",
    "USPDX" => "USPTJ",
    "IDPJG" => "IDPNJ",
    "INVIZ" => "INVIG",
    "CNAQG" => "CNANJ",
    "CNHFE" => "CNHFI",
    "CNHKG" => "HKCL4",
    "CNZNG" => "CNZJI",
    "LYELK" => "LYKHO",
    "LYTIP" => "LBKYE",
    "CRMOB" => "CRPMN"
  }.freeze

  def perform
    org = Organizations::Organization.find_by(slug: "saco")
    VALID_TO_INVALID_MAP.each do |missing_correct_locode, existing_incorrect_lcoode|
      saco_nexus = Legacy::Nexus.find_by(organization: org, locode: existing_incorrect_lcoode)
      saco_nexus.update(locode: missing_correct_locode)
      saco_nexus.hubs.each { |hub| hub.update(hub_code: missing_correct_locode) }
    end
  end
end
