# frozen_string_literal: true

FactoryBot.define do
  factory :witness, class: 'Witness' do
    skip_create
    initialize_with do
      new(attributes)
    end
    siglum { Faker::Alphanumeric.unique.alpha(number: 3) }
    name { Faker::Lorem.sentence }

    trait :with_project do
      parent { build(:project) }
    end
  end
end
