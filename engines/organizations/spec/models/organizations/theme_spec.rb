# frozen_string_literal: true

require "rails_helper"

module Organizations
  RSpec.describe Theme, type: :model do
    let(:theme) { FactoryBot.create(:organizations_theme) }

    context "when updating one of the colours in the colour scheme" do
      let(:new_dark) { "#0fffff" }

      it "updates `dark` to `#0fffff`" do
        theme.update(dark: new_dark)
        expect(theme.reload.color_scheme["dark"]).to eq new_dark
      end

      context "when updating with a colour which is not present in the default schema yaml nor in color_scheme" do
        it "updates the theme with the new color" do
          theme.color_scheme["red"] = "#0f2345"
          theme.save!
          expect(theme.reload.red).to eq "#0f2345"
        end
      end

      context "when colour is present in color scheme and not in default schema" do
        let(:theme) { FactoryBot.create(:organizations_theme, color_scheme: { blue: "#034567" }) }

        it "returns the blue colour from the color scheme" do
          expect(theme.blue).to eq "#034567"
        end
      end
    end

    context "when colour is not a part of the colour scheme" do
      it "returns nil" do
        expect(theme.color_scheme["teal"]).to eq nil
      end
    end

    context "when key is not a part of the color scheme but available in default schema" do
      let(:theme) { FactoryBot.create(:organizations_theme, color_scheme: {}) }

      it "value is fetched from the default schema" do
        expect(theme.dark).to eq ""
      end
    end

    it "raises method missing when a non defined method is called" do
      expect { theme.random_method }.to raise_error(NoMethodError)
    end
  end
end
