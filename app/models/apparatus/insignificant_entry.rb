# frozen_string_literal: true

module Apparatus
  class InsignificantEntry < Entry
    delegate :insignificant_variants, to: :token
    alias additional_variants insignificant_variants
  end
end
