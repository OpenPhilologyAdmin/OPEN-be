# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    initialize_with do
      new(attributes)
    end

    user { create(:user, :admin, :approved) }
    token { create(:token) }

    body { Faker::String.random(length: 200) }
  end
end
