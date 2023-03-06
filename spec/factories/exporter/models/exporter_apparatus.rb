# frozen_string_literal: true

FactoryBot.define do
  factory :exporter_apparatus, class: 'Exporter::Models::Apparatus' do
    skip_create
    initialize_with do
      new(**attributes)
    end
    selected_variant { build(:token_grouped_variant, :selected) }
    secondary_variants { build_list(:token_grouped_variant, 2, :secondary) }
    insignificant_variants { build_list(:token_grouped_variant, 2, :insignificant) }
    apparatus_options { build(:apparatus_options) }
  end
end
