# frozen_string_literal: true

FactoryBot.define do
  factory :extracted_data, class: 'Importer::ExtractedData' do
    skip_create
    initialize_with do
      new(attributes)
    end

    tokens do
      [
        [0,
         [
           [
             {
               witness:  'A',
               t:        'Lorem ipsum dolor sit amet',
               selected: false,
               deleted:  false
             }
           ]
         ],
         [
           {
             t:         'Lorem ipsum dolor sit amet',
             witnesses: ['A'],
             selected:  false
           }
         ]],
        [1,
         [
           [
             {
               witness:  'A',
               t:        'Consectetur adipiscing elit',
               selected: false,
               deleted:  false
             }
           ]
         ],
         [
           {
             t:         'Consectetur adipiscing elit',
             witnesses: ['A'],
             selected:  false
           }
         ]]
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
