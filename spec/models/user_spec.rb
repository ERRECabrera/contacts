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
    let(:valid_avatar) { FactoryHelpers.get_valid_image('avatar') }

    let(:invalid_phones) { FactoryHelpers.get_invalid_phones }
    let(:invalid_avatar) { FactoryHelpers.get_invalid_image('avatar') }

    #relations
    it { should have_many(:relations) }
    it { should have_many(:contacts) }
    it { should have_many(:friends) }
    it { should have_many(:family) }
    it { should have_many(:partners) }

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

  #scopes
  describe 'scopes' do
    let(:valid_user_attributes) { FactoryGirl.build(:valid_user).attributes }
    let(:valid_contact_attributes) { FactoryGirl.build(:valid_user).attributes }
    let(:valid_type_relation) { 'friend' }

    let(:create_basic_relation) {
        user = User.create!(valid_user_attributes)
        contact = User.create!(valid_contact_attributes)
        user.create_relation(valid_type_relation,contact.id)
    }

    context 'named scope' do
      before { create_basic_relation }

      context 'given a name of a user who exists in ddbb' do
        it 'should return a user list with name equal to the name given' do
          expect(User.named(valid_user_attributes['name'])).to be_any
          expect(User.first.friends.named(valid_contact_attributes['name'])).to be_any
        end
      end

      context 'given a name of a user who doesnt exist in ddbb' do
        it 'should dont return a user list' do
          expect(User.named('lalala')).to be_empty
          expect(User.first.friends.named('lalala')).to be_empty
        end
      end
    end

    context 'surnamed scope' do
      before { create_basic_relation }

      context 'given a surnames of a user who exists in ddbb' do
        it 'should return a user list with name equal to the name given' do
          expect(User.surnamed([valid_user_attributes['surnames'].sample])).to be_any
          expect(User.first.friends.surnamed([valid_contact_attributes['surnames'].sample])).to be_any
        end
      end

      context 'given a surname of a user who doesnt exist in ddbb' do
        it 'should dont return a user list' do
          expect(User.surnamed(['lalala'])).to be_empty
          expect(User.first.friends.surnamed(['lalala'])).to be_empty
        end
      end
    end

    context 'duplicate scope' do
      before { create_basic_relation }

      context 'when a user exists in ddbb' do
        it 'should return a duplicate' do
          expect(
            User.duplicate(
              valid_user_attributes['name'],
              valid_user_attributes['surnames'],
              valid_user_attributes['email']
              )
          ).to be_any
        end
      end

      context 'when a user doesnt exists in ddbb' do
        it 'should dont return a duplicate' do
          expect(User.duplicate('Lolo',['lalala'],'test@gmail.com')).to be_empty
        end
      end
    end

  end

  #instance methods
  let(:valid_user) { FactoryGirl.create(:valid_user) }
  let(:valid_contact) { FactoryGirl.create(:valid_user) }
  let(:invalid_contact_id) { 8_000 }
  let(:valid_type_relation) { 'friend' }
  let(:invalid_type_relation) { 'comida' }

  describe '#create_relation' do
    context 'with a valids arguments' do
      it 'should create two new relations between users, direct and inverse' do
        expect {
          valid_user.create_relation(valid_type_relation,valid_contact.id)
        }.to change(Relation, :count).by(2)
        expect(valid_user.friends.count).to eq(1)
        expect(valid_contact.friends.count).to eq(1)
      end
    end

    context 'with a invalids arguments' do
      it 'if type present is invalid, should raise ArgumentError' do
        expect {
          valid_user.create_relation(invalid_type_relation,invalid_contact_id)
        }.to raise_error ArgumentError
      end

      it 'if type present is valid, should return false' do
        status = valid_user.create_relation(valid_type_relation,invalid_contact_id)
        expect(status).to be_falsey
      end
    end

  end

  describe '#has_relation?' do
    context 'when user has not a relation before with a contact' do
      it 'should return false' do
        expect(valid_user.has_relation?(valid_contact.id)).to be_falsey
      end
    end

    context 'when user has a relation before with a contact' do
      it 'should return truthy (is a relation obj)' do
        valid_contact_id = valid_contact.id
        valid_user.create_relation(valid_type_relation,valid_contact_id)
        expect(valid_user.has_relation?(valid_contact_id)).to be_truthy
      end
    end
  end

end
