# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class Group < ExcelDataServices::V4::Extractors::Base
        def extracted
          @extracted ||= [default_group_frame, group_name_frame, group_id_frame].compact
            .inject(Rover::DataFrame.new) do |result, group_frame|
              result.concat(group_frame)
            end
        end

        def group_name_frame
          return if rows_identified_by_name_only.blank?

          @group_name_frame ||= Rover::DataFrame.new(
            rows_identified_by_name_only.left_join(extracted_frame, on: { "group_name" => "group_name" }),
            types: frame_types
          )
        end

        def group_id_frame
          return if rows_identified_by_id.blank?

          @group_id_frame ||= Rover::DataFrame.new(
            rows_identified_by_id.left_join(extracted_frame, on: { "group_id" => "group_id" }),
            types: frame_types
          )
        end

        def default_group_frame
          return if rows_for_default_group.blank?

          @default_group_frame ||= rows_for_default_group.left_join(default_group_id_frame, on: { "organization_id" => "organization_id" })
        end

        def frame_data
          Groups::Group.where(organization_id: Organizations.current_id)
            .select("id as group_id, name AS group_name, organization_id").as_json.map do |group|
              group.merge("group_found" => true)
            end
        end

        def frame_types
          { "group_id" => :object, "group_name" => :object }
        end

        def default_group_id_frame
          @default_group_id_frame ||= extracted_frame[extracted_frame["group_name"] == "default"]
        end

        def rows_identified_by_id
          @rows_identified_by_id ||= frame[!frame["group_id"].missing] if frame.include?("group_id")
        end

        def rows_identified_by_name_only
          @rows_identified_by_name_only ||= (rows_without_group_id[!rows_without_group_id["group_name"].missing] if frame_contains_group_name? && rows_without_group_id.present?)
        end

        def rows_for_default_group
          @rows_for_default_group ||= (rows_without_group_id[rows_without_group_id["group_name"].missing] if frame_contains_group_name? && rows_without_group_id.present?)
        end

        def rows_without_group_id
          @rows_without_group_id ||= frame[frame["group_id"].missing]
        end

        def frame_contains_group_name?
          @frame_contains_group_name ||= frame.include?("group_name")
        end
      end
    end
  end
end
