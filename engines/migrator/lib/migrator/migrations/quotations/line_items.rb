# frozen_string_literal: true

module Migrator
  module Migrations
    module Quotations
      class LineItems < Base
        def data
          <<~SQL
            UPDATE quotations_line_items
            SET original_amount_currency = amount_currency, original_amount_cents = amount_cents
            WHERE original_amount_currency IS NULL
            AND original_amount_cents IS NULL
          SQL
        end

        def count_required
          count("SELECT count(*) FROM quotations_line_items
                 WHERE original_amount_currency IS NULL
                 AND original_amount_cents IS NULL ")
        end
      end
    end
  end
end
