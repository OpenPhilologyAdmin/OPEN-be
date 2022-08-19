# frozen_string_literal: true

module FormattableT
  EMPTY_VALUE_PLACEHOLDER = 'Ø'
  extend ActiveSupport::Concern

  def formatted_t
    return t if t.present?

    EMPTY_VALUE_PLACEHOLDER
  end
end
