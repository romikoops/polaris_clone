# frozen_string_literal: true

module Migrator
  module Migrations
    module Quotations
      class WithoutTenders < Base
        def data
          <<~SQL
            with without_tenders as (select quotations_quotations.id
              from quotations_quotations
              left join quotations_tenders on quotations_quotations.id = quotations_tenders.quotation_id
              where quotations_tenders.quotation_id is null)
            update quotations_quotations
            set error_class = 'StandardError'
            where id in (select id from without_tenders);
          SQL
        end

        def count_required
          count("
            WITH without_tenders as (select quotations_quotations.id
              from quotations_quotations
              left join quotations_tenders on quotations_quotations.id = quotations_tenders.quotation_id
              where quotations_tenders.quotation_id is null)
            SELECT COUNT(*) from quotations_quotations
            WHERE quotations_quotations.id in (select id from without_tenders);
          ")
        end
      end
    end
  end
end
