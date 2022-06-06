# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Lorem.characters(number: 8, min_alpha: 1, min_numeric: 1) }
    confirmed_at { Time.zone.today }
    name { Faker::Name.name }

    trait :admin do
      role { :admin }
    end

    trait :approved do
      approved_at { Time.zone.today }
    end

    trait :not_approved do
      approved_at { nil }
    end

    trait :not_confirmed do
      confirmed_at { nil }
    end
  end
end
