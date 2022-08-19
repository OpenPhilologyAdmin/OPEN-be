# frozen_string_literal: true

FactoryBot.define do
  factory :token do
    project { create(:project) }
    index { Faker::Number.positive }
    variants do
      project.witnesses.map do |witness|
        build(:token_variant, witness: witness.siglum)
      end
    end

    grouped_variants do
      project.witnesses.map do |witness|
        build(:token_grouped_variant, witnesses: [witness.siglum])
      end
    end

    editorial_remark { build(:token_editorial_remark) }

    trait :without_project do
      project { nil }
    end

    trait :variant_selected do
      project { create(:project, witnesses_number: 3) }
      variants do
        project.witnesses.map do |witness|
          build(:token_variant,
                witness: witness.siglum)
        end
      end

      # first variant is the selected one
      grouped_variants do
        project.witnesses.map.with_index do |witness, index|
          build(:token_grouped_variant,
                witnesses: [witness.siglum],
                selected:  index.zero?,
                possible:  index.zero?)
        end
      end
    end

    trait :variant_selected_and_secondary do
      project { create(:project, witnesses_number: 3) }
      variants do
        project.witnesses.map do |witness|
          build(:token_variant,
                witness: witness.siglum)
        end
      end

      # first variant is the selected one, others are possible
      grouped_variants do
        project.witnesses.map.with_index do |witness, index|
          build(:token_grouped_variant,
                witnesses: [witness.siglum],
                selected:  index.zero?,
                possible:  true)
        end
      end
    end

    trait :without_editorial_remark do
      editorial_remark { nil }
    end
  end
end
