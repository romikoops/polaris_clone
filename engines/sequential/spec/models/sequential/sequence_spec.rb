# frozen_string_literal: true

require 'rails_helper'

load 'support/disable_transactional_specs.rb'

module Sequential
  RSpec.describe Sequence, type: :model do
    context 'When counting' do
      before do
        Sequence.create!(name: :shipment_invoice_number, value: 0)
      end

      it 'Does not count unless called from within a transaction' do
        expect { Sequence.next(:shipment_invoice_number) }.to raise_error(ActiveRecord::Rollback)
      end

      it 'Counts sequentially' do
        first = ActiveRecord::Base.transaction  { Sequence.next(:shipment_invoice_number) }
        second = ActiveRecord::Base.transaction { Sequence.next(:shipment_invoice_number) }
        third = ActiveRecord::Base.transaction  { Sequence.next(:shipment_invoice_number) }
        expect(first).to eq(1)
        expect(second).to eq(2)
        expect(third).to eq(3)
      end

      it 'Handles race conditions - counts without gaps' do
        all_threads_initialized = false
        threads_num = 3
        threads = Array.new(threads_num) {
          Thread.new do
            true until all_threads_initialized
            ActiveRecord::Base.transaction { Sequence.next(:shipment_invoice_number) }
          end
        }
        all_threads_initialized = true
        threads.each(&:join)
        expect(Sequence.last.value).to eq(threads_num)
      end

      it 'does not allow creating 2 counters of the same type' do
        expect { Sequence.create!(name: :shipment_invoice_number) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
