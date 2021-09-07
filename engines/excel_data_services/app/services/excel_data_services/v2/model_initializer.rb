# frozen_string_literal: true

module ExcelDataServices
  module V2
    class ModelInitializer
      def initialize(model:, data:)
        @model = model
        @data = data
      end

      def perform
        return init_model_instance(row: data) if data.is_a?(Hash)

        data.map do |row|
          init_model_instance(row: row)
        end
      end

      private

      attr_reader :data, :model

      def init_model_instance(row:)
        model.new(row.except(*association_keys)).tap do |new_record|
          associations_for_insertion.each do |association_for_insertion|
            new_record.send(
              "#{association_for_insertion.key}=",
              ModelInitializer.new(
                model: association_for_insertion.model,
                data: row[association_for_insertion.key]
              ).perform
            )
          end
        end
      end

      def associations_for_insertion
        @associations_for_insertion ||= model_associations
          .map { |association| WrappedAssociation.new(association: association) }
          .select { |association| data_keys.include?(association.key) }
      end

      def model_associations
        model.reflect_on_all_associations(:has_many) + model.reflect_on_all_associations(:has_one)
      end

      def association_keys
        @association_keys ||= associations_for_insertion.map(&:key)
      end

      def data_keys
        @data_keys ||= (data.is_a?(Hash) ? data : data.first).keys
      end

      class WrappedAssociation
        def initialize(association:)
          @association = association
        end

        attr_reader :association

        delegate :options, to: :association

        def model
          association.klass
        end

        def key
          association.name.to_s
        end
      end
    end
  end
end
