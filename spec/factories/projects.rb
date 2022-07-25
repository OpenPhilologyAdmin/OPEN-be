# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    transient do
      creator { create(:user, :admin, :approved) }
      witnesses_number { 3 }
    end

    name { Faker::Lorem.word }
    default_witness { Faker::Alphanumeric.alpha(number: 2).upcase }

    witnesses do
      build_list(:witness, witnesses_number) do |witness, index|
        next unless index.zero?

        # make first witness the default one
        witness.siglum = default_witness
      end
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

    trait :with_creator do
      after(:create) do |record, evaluator|
        create(:project_role, :owner, project: record, user: evaluator.creator)
      end
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
