# frozen_string_literal: true

FactoryBot.define do
  factory :extracted_data, class: 'Importer::Extractors::Models::ExtractedData' do
    skip_create
    initialize_with do
      new(attributes)
    end

    tokens do
      [
        [
          {
            witness:  'A',
            t:        Faker::Lorem.sentence,
            selected: false,
            deleted:  false
          }.stringify_keys
        ]
      ]
    end
    witnesses do
      [
        {
          siglum: 'A',
          name:   'A document'
        }.stringify_keys
      ]
    end
  end
end
