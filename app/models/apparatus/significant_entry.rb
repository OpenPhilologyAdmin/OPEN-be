# frozen_string_literal: true

module Apparatus
  class SignificantEntry < Entry
    delegate :secondary_variants, to: :token
    alias additional_variants secondary_variants
  end
end
