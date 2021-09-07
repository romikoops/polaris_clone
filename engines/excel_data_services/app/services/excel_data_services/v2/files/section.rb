# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Files
      class Section
        # A section is defined by a config file that runs a pipeline of Operations that extract, manipulate, validate and insert data based on the classes invoked.
        attr_reader :state

        delegate :xlsx, :section, to: :state
        delegate :sheets, to: :xlsx

        def self.state(state:)
          new(state: state).perform
        end

        def initialize(state:)
          @state = state
        end

        def perform
          @state.frame = data
          @state.errors |= errors
          execute_actions(actions: row_validations)
          nested_pipeline(connected_actions: dependency_actions)
          state
        end

        def nested_pipeline(connected_actions:)
          connected_action = connected_actions.first
          return if failed?

          if (importer = connected_action.importer)
            importer.model.transaction do
              inner_transaction_loop(connected_actions: connected_actions)
            end
          else
            inner_transaction_loop(connected_actions: connected_actions)
          end
        end

        def inner_transaction_loop(connected_actions:)
          if connected_actions.length > 1
            nested_pipeline(connected_actions: connected_actions[1..])
          else
            execute_pipeline
          end
        end

        def execute_pipeline
          dependency_actions.reverse_each do |connected_action|
            execute_actions(actions: connected_action.actions)
            next if failed?

            @state = connected_action.importer.state(state: state)
            next unless failed?
            raise ActiveRecord::Rollback if atomic_insert?

            break @state
          end
        end

        def data
          @data ||= sheet_objects.inject(Rover::DataFrame.new) do |result, sheet_object|
            result.concat(sheet_object.perform)
          end
        end

        def execute_actions(actions:)
          actions.each do |action|
            break if failed?

            @state = action.state(state: state)
          end
        end

        def valid?
          all_sheets_meet_requirements? && required_columns_present? && errors.empty?
        end

        def errors
          @errors ||= sheet_objects.flat_map(&:errors)
        end

        def failed?
          state.errors.present?
        end

        def sheet_objects
          @sheet_objects ||= sheets.map { |sheet_name| ExcelDataServices::V2::Files::Tables::Sheet.new(section: self, sheet_name: sheet_name) }
        end

        def required_columns_present?
          columns.select(&:required).all?(&:valid?)
        end

        def column_types
          validated_columns.map(&:frame_type).reduce(&:merge)
        end

        def rows
          @rows ||= columns.first.cells.map(&:row).drop(1)
        end

        def validated_columns
          @validated_columns ||= columns.select { |col| sheets.include?(col.sheet_name) && col.valid? }
        end

        def all_sheets_meet_requirements?
          requirements.all?(&:valid?)
        end

        delegate :columns, :requirements, :prerequisites, :operations, :dynamic_columns, :model,
          :row_validations, :sorted_dependencies, :dependency_actions, to: :sheet_parser

        private

        def sheet_parser
          @sheet_parser ||= SheetParser.new(type: "section", section: section, state: state)
        end

        def atomic_insert?
          OrganizationManager::ScopeService.new(
            target: nil, organization: organization
          ).fetch(:atomic_insert)
        end
      end
    end
  end
end
