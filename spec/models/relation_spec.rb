require 'rails_helper'

RSpec.describe Relation, type: :model do

  #factorys validation
  describe 'factorys' do
    it 'should have a valid factory for a relation' do
      expect(FactoryGirl.build(:valid_relation)).to be_valid
    end

    it 'should have a invalid factory for a relation' do
      expect(FactoryGirl.build(:invalid_relation)).not_to be_valid
    end
  end

  let(:valid_relation) { FactoryGirl.create(:valid_relation) }
  let(:dummy_relation) { FactoryGirl.build(:valid_relation) }
  let(:valid_user) { FactoryGirl.create(:valid_user) }
  let(:valid_contact) { FactoryGirl.create(:valid_user) }
  let(:valid_type_relation) { 'friend' }

  #attributes validation
  describe 'validations' do

    let(:valid_user_id) { FactoryGirl.create(:valid_user).id }
    let(:valid_contact_id) { FactoryGirl.create(:valid_user).id }
    let(:valid_type) { Relation::TYPE_RELATIONS.keys.map!(&:to_s).sample }

    let(:invalid_user_id) { 'a' }
    let(:invalid_contact_id) { 4_000 }
    let(:invalid_relation_by_type) { FactoryGirl.build(:invalid_relation)._type = 'comida' }

    #relations
    it { should belong_to(:user) }
    it { should belong_to(:contact) }

    #presence
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:contact_id) }
    it { should validate_presence_of(:_type) }

    #uniqueness - no duplicates
    it {
      first_time_direct = valid_user.create_relation(valid_type_relation,valid_contact.id)
      #first_time_inverse relation is auto created
      second_time_direct = valid_user.create_relation(valid_type_relation,valid_contact.id)
      second_time_inverse = valid_contact.create_relation(valid_type_relation,valid_user.id)
      expect(first_time_direct).to be_truthy
      expect(second_time_direct).to be_falsey
      expect(second_time_inverse).to be_falsey
    }

    #numericality
    it { should validate_numericality_of(:user_id) }
    it { should validate_numericality_of(:contact_id) }

    #valid_values
    it { should allow_value(valid_user_id).for(:user_id) }
    it { should allow_value(valid_contact_id).for(:contact_id) }
    it { should allow_value(valid_type).for(:_type) }

    #invalid_values
    it { should_not allow_value(invalid_user_id).for(:user_id) }
    it { should_not allow_value(invalid_contact_id).for(:contact_id) }
    it { expect{ invalid_relation_by_type }.to raise_error ArgumentError }

  end

  #callbacks
  describe 'callbacks' do
    context 'when relation is created' do
      it 'should run a callback method' do
        expect_any_instance_of(Relation).to receive(:create_inverse_relation).once
        valid_relation
      end
    end
  end

  #class methods
  describe '::exist_before?' do
    context 'when there is a relation before' do
      it 'should return true' do
        valid_relation
        expect(Relation.exist_before?(valid_relation.user_id,valid_relation.contact_id)).to be_truthy
      end
    end

    context 'when there is not a relation before' do
      it 'should return false' do
        expect(Relation.exist_before?(valid_user.id,valid_contact.id)).to be_falsey
      end
    end
  end

  #instance methods
  describe '#exist_inverse_relation?' do
    context 'when there is a relation before' do
      it 'should return true' do
        expect(valid_relation.send(:exist_inverse_relation?)).to be_truthy
      end
    end

    context 'when there is not a relation before' do
      it 'should return false' do
        expect(dummy_relation.send(:exist_inverse_relation?)).to be_falsey
      end
    end
  end

  describe '#create_inverse_relation' do
    it 'should create two new relations between users, direct and inverse' do
      expect {
        valid_relation.send(:create_inverse_relation)
      }.to change(Relation, :count).by(2)
      expect(Relation.first.user_id).to eq(Relation.last.contact_id)
      expect(Relation.first.contact_id).to eq(Relation.last.user_id)
    end
  end

end
