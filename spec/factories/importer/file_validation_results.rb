# frozen_string_literal: true

FactoryBot.define do
  factory :file_validation_result, class: 'Importer::FileValidationResult' do
    skip_create
    initialize_with do
      new(attributes)
    end

    errors { [] }

    trait :unsuccessful do
      errors { ['missing required keys'] }
    end
  end
end
