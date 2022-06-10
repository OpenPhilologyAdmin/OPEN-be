# frozen_string_literal: true

FactoryBot.define do
  factory :extracted_data, class: 'Importer::ExtractedData' do
    skip_create
    initialize_with do
      new(attributes)
    end

    tokens do
      build_list(:token, 3, :without_project)
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
