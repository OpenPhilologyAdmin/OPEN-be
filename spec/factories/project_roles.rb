# frozen_string_literal: true

FactoryBot.define do
  factory :project_role do
    user
    project

    trait :owner do
      role { :owner }
    end
  end
end
