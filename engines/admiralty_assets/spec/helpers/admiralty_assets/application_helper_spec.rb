# frozen_string_literal: true

require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ApplicationHelper. For example:
#
# describe ApplicationHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
module AdmiraltyAssets
  RSpec.describe ApplicationHelper, type: :helper do
    include AdmiraltyAssets::ApplicationHelper

    describe 'controller_classes' do
      it 'returns controller specific CSS class names' do
        expect(controller_classes).to eq('application application application_')
      end
    end

    describe 'controller_class' do
      it 'returns namespaces class' do
        expect(controller_class).to eq('application')
      end
    end

    describe 'controller_action_class' do
      it 'returns controller class with action' do
        expect(controller_action_class).to eq('application_')
      end
    end
  end
end
