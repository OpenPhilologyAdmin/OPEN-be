# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    user { create(:user, :admin, :approved) }
    token { create(:token) }

    body { Faker::String.random(length: 200) }
  end
end
