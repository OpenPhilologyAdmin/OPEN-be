# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8) }
    confirmed_at { Time.zone.today }
    name { Faker::Name.name }

    trait :admin do
      role { :admin }
    end
  end
end
