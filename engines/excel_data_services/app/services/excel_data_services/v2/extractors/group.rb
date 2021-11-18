# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class Group < ExcelDataServices::V2::Extractors::Base
        def extracted
          @extracted ||= default_group_frame
            .concat(group_name_frame) # Join in all that have Group Name
            .concat(group_id_frame) # Join in all that have Group ID
        end

        def group_name_frame
          @group_name_frame ||= Rover::DataFrame.new(
            frame[(!frame["group_name"].missing) & (frame["group_id"].missing)].left_join(extracted_frame, on: { "group_name" => "group_name" }),
            types: frame_types
          )
        end

        def group_id_frame
          @group_id_frame ||= Rover::DataFrame.new(
            frame[!frame["group_id"].missing].left_join(extracted_frame, on: { "group_id" => "group_id" }),
            types: frame_types
          )
        end

        def default_group_frame
          @default_group_frame ||= Rover::DataFrame.new(
            frame[(frame["group_name"].missing) & (frame["group_id"].missing)],
            types: frame_types
          ).tap do |tapped_frame|
            tapped_frame["group_id"] = default_group_id
          end
        end

        def frame_data
          Groups::Group.where(organization_id: Organizations.current_id)
            .select("id as group_id, name AS group_name")
        end

        def frame_types
          { "group_id" => :object, "group_name" => :object }
        end

        def default_group_id
          Groups::Group.find_by(organization_id: Organizations.current_id, name: "default").id
        end
      end
    end
  end
end
