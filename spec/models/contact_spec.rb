require 'rails_helper'


describe Contact, type: :model do
  context 'validations' do

    let(:user) { build(:user)}

    let!(:contact_one) { create(:contact, user: user) }

    let(:contact_two) { build(:contact, user: user) }

    let(:contact_three) { build(:contact, user: user, first_name: "Johnny") }

    context 'Different first names' do 
      it 'Should be validate the uniqueness' do
        contact_one.should be_valid
        contact_three.should be_valid
      end
    end

    context 'Same information' do
      it 'Should not validate because they are not unique' do
        contact_two.should be_invalid
      end
    end

  end
end
