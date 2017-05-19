require 'rails_helper'
require_relative '../factories/factory_helpers.rb'

RSpec.describe User, type: :model do

  #factorys validation
  describe 'factorys' do
    it 'should have a valid factory for a user' do
      expect(FactoryGirl.build(:valid_user)).to be_valid
    end

    it 'should have a invalid factory for a user' do
      expect(FactoryGirl.build(:invalid_user)).not_to be_valid
    end
  end

  #attributes validation
  describe 'validations' do

    let(:valid_name) { Faker::Name.first_name }
    let(:valid_surnames) { FactoryHelpers.get_surnames }
    let(:valid_email) { Faker::Internet.free_email }
    let(:valid_phones) { FactoryHelpers.get_valid_phones }
    let(:invalid_phones) { FactoryHelpers.get_invalid_phones }
    let(:valid_avatar) { FactoryHelpers.get_valid_image('avatar') }
    let(:invalid_avatar) { FactoryHelpers.get_invalid_image('avatar') }

    #presence
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:surnames) }
    it { should validate_presence_of(:email) }

    #uniqueness
    it { should validate_uniqueness_of(:email) }

    #absence
    it { should allow_value(nil).for(:phones) }
    it { should allow_value(nil).for(:avatar) }

    #valid_values
    it { should allow_value(valid_name).for(:name) }
    it { should allow_value(valid_surnames).for(:surnames) }
    it { should allow_value(valid_email).for(:email) }
    it { should allow_value(valid_phones).for(:phones) }
    it { should allow_value(valid_avatar).for(:avatar) }

    #invalid_values
    it { should_not allow_value(invalid_phones).for(:phones) }
    it { should_not allow_value(invalid_avatar).for(:avatar) }

  end

end
