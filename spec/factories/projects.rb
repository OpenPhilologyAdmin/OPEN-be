# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { Faker::Lorem.word }
    default_witness { 'D' }
    witnesses do
      [
        {
          witness: 'D',
          name:    'D witness'
        },
        {
          witness: 'E',
          name:    'E witness'
        }
      ]
    end

    trait :status_processing do
      status { :processing }
    end

    trait :status_processed do
      status { :processed }
    end

    trait :status_invalid do
      status { :invalid }
    end

    trait :with_source_file do
      after(:build) do |record|
        record.source_file.attach(
          io:           File.open(Rails.root.join('spec/fixtures/sample_project.txt')),
          filename:     "#{rand}_project.txt",
          content_type: 'text/plain'
        )
      end
    end

    trait :with_json_source_file do
      after(:build) do |record|
        record.source_file.attach(
          io:           File.open(Rails.root.join('spec/fixtures/sample_project.json')),
          filename:     "#{rand}_project.json",
          content_type: 'application/json'
        )
      end
    end

    trait :with_simplified_json_source_file do
      after(:build) do |record|
        record.source_file.attach(
          io:           File.open(Rails.root.join('spec/fixtures/sample_simplified_project.json')),
          filename:     "#{rand}_project.json",
          content_type: 'application/json'
        )
      end
    end
  end
end
