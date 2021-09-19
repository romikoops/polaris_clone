# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Notes < ExcelDataServices::Inserters::Base
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

        note = Legacy::Note.find_or_initialize_by(header: target.name, target: target, organization: organization)
        note.assign_attributes(
          header: target.name,
          target: target,
          body: params[:note],
          contains_html: params[:contains_html]
        )
        add_stats(note, params[:row_nr])
        note.save

        note
      end

      def determine_target(params:)
        if params[:country].present? && params[:unlocode].blank?
          ::Legacy::Country.find_by(code: params[:country].upcase)
        else
          ::Legacy::Nexus.find_by(locode: params[:unlocode], organization: organization)
        end
      end
    end
  end
end
