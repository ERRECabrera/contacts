FactoryGirl.define do
  factory :relation do
    #common attributes
    user_id { FactoryGirl.create(:valid_user).id }
    contact_id { FactoryGirl.create(:valid_user).id }
    _type { Relation::TYPE_RELATIONS.keys.map!(&:to_s).sample }

    factory :valid_relation

    factory :invalid_relation do
      user_id { 'a' }
      contact_id { 4_000 }
    end
  end
end
