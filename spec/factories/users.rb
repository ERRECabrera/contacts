require_relative './factory_helpers.rb'

FactoryGirl.define do
  factory :user do
    #common attributes
    name { Faker::Name.first_name }
    surnames { FactoryHelpers.get_surnames }
    email { Faker::Internet.free_email(name) }
    phones { FactoryHelpers.get_valid_phones }
    avatar { FactoryHelpers.get_valid_image('avatar') }

    factory :valid_user

    factory :invalid_user do
      phones { FactoryHelpers.get_invalid_phones }
      avatar { FactoryHelpers.get_invalid_image('avatar') }
    end

  end
end
