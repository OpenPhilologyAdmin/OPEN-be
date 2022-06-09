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
          }
        ]
      ]
    end
    witnesses do
      [
        {
          siglum: 'A',
          name:   'A document'
        }
      ]
    end
  end
end
