# frozen_string_literal: true

module Api
  class FilterParamValidator
    include ActiveModel::Validations

    attr_reader :default_filter_params

    REQUIRED_DATE_FORMAT = "%Y-%m-%d"
    DEFAULT_BEFORE_DATE = Time.zone.today
    DEFAULT_AFTER_DATE = Time.zone.at(1)
    DEFAULT_DIRECTION = "asc"

    DIRECTION_OPTIONS = %w[
      asc
      desc
    ].freeze

    SUPPORTED_FILTERS = %i[search_by sort_by search_query direction before_date after_date].freeze

    validate :search_by_validation
    validate :sort_by_validation
    validate :activity_validation

    def initialize(supported_search_options, supported_sort_options, default_filter_params, options:)
      @default_filter_params = default_filter_params
      SUPPORTED_FILTERS.each { |filter| define_variables(filter, options[filter]) }
      define_variables("search_options", supported_search_options)
      define_variables("sort_options", supported_sort_options)
      @direction = DEFAULT_DIRECTION if direction.blank?
    end

    def to_h
      return {} if errors.present?

      filters = {}.tap do |filter|
        filter.merge!(sorted_by) if sort_by.present?
        filter.merge!(search) if search_by.present?
        filter.merge!(activity) if dates_present?
      end
      return default_filter_params if filters.blank?

      filters
    end

    private

    def search_by_validation
      return if search_by.blank?

      errors.add(:search_by, error_code: "INVALID_SEARCH_BY_OPTION", error_message: "#{search_by} is unsupported search by option, options available for search by are : #{search_options}") unless search_options.include?(search_by.downcase)

      errors.add(:search_by, error_code: "SEARCH_QUERY_MISSING", error_message: "search query needs to be specified with search by") if search_query.blank?
    end

    def sort_by_validation
      return if sort_by.blank?

      errors.add(:sort_by, error_code: "INVALID_SORT_BY_OPTION", error_message: "#{sort_by} is unsupported sort_by option, options available for sorting are : #{sort_options}") unless sort_options.include?(sort_by.downcase)

      errors.add(:sort_by, error_code: "INVALID_DIRECTION_OPTION", error_message: "#{direction} is unsupported direction option, options available for direction are : #{DIRECTION_OPTIONS}") unless DIRECTION_OPTIONS.include?(direction.downcase)
    end

    def activity_validation
      return unless dates_present?

      [before_date, after_date].compact.each do |date|
        Date.strptime(date, REQUIRED_DATE_FORMAT)
      rescue ArgumentError
        errors.add(:date, error_code: "INVALID_DATE", error_message: "supported date format is `YYYY-mm-dd`")
      end
    end

    def sorted_by
      { sorted_by: [sort_by, direction].compact.join("_") }
    end

    def search
      { "#{search_by}_search".to_sym => search_query }
    end

    def dates_present?
      [before_date, after_date].any?
    end

    def activity
      { activity_search: Range.new(formatted_after_date, formatted_before_date) }
    end

    def formatted_after_date
      after_date.present? ? Date.strptime(after_date, REQUIRED_DATE_FORMAT) : DEFAULT_AFTER_DATE
    end

    def formatted_before_date
      before_date.present? ? Date.strptime(before_date, REQUIRED_DATE_FORMAT) : DEFAULT_BEFORE_DATE
    end

    def define_variables(name, value)
      instance_variable_set("@#{name}", value)
      self.class.instance_eval { attr_accessor name.to_sym }
    end
  end
end
