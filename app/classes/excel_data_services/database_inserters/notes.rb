# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserters
    class Notes < Base
      def perform
        data.each do |params|
          update_or_create_note(params: params)
        end

        stats
      end

      private

      def update_or_create_note(params:)
        target = determine_target(params: params)
        return unless target

        note = Note.create(
          header: target.name,
          target: target,
          body: params[:note],
          contains_html: params[:contains_html],
          tenant: tenant
        )
        add_stats(note)

        note
      end

      def determine_target(params:)
        if params[:country].present? && params[:unlocode].blank?
          ::Legacy::Country.find_by(code: params[:country].upcase)
        else
          ::Legacy::Nexus.find_by(locode: params[:unlocode], tenant: tenant)
        end
      end
    end
  end
end
