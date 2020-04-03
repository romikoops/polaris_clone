# frozen_string_literal: true

module Analytics
  module Dashboard
    class Base < Analytics::Base
      def self.data(user:, start_date: 30.days.ago, end_date: DateTime.now, sandbox: nil)
        new(user: user, start_date: start_date, end_date: end_date, sandbox: sandbox).data
      end

      private

      def tally(requests:, grouping_attribute:, order_by_count: true, order: nil, limit: nil)
        result = requests.group(grouping_attribute)
        result = result.order("#{order_by_count ? 'count_all' : grouping_attribute} #{order}") if order
        result = result.limit(limit) if limit
        result.count
              .map { |label, count| { label: label, count: count } }
      end
    end
  end
end
