# frozen_string_literal: true

module Notifications
  class CargoUnitDecorator < Draper::Decorator
    delegate_all

    def dimensions
      [
        length,
        width,
        height
      ].map(&:format).join(" x ") + " " + I18n.t("notifications.request_mailer.request_created.dimensions_key")
    end

    def cargo_type
      (cargo_class == "lcl" ? colli_type : cargo_class).humanize
    end

    def imo_classes
      @imo_classes ||= commodity_infos.where.not(imo_class: nil)
    end

    def commodity_codes
      @commodity_codes ||= commodity_infos.where.not(hs_code: nil)
    end
  end
end
