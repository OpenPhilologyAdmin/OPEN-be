# frozen_string_literal: true

FactoryBot.define do
  factory :token_editorial_remark, class: 'TokenEditorialRemark' do
    skip_create
    initialize_with do
      new(attributes)
    end
    type { TokenEditorialRemark::EDITORIAL_REMARK_TYPES.sample }
    t { Faker::Lorem.sentence }
  end
end
