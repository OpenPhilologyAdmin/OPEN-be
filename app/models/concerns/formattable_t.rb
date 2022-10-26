# frozen_string_literal: true

module FormattableT
  NIL_VALUE_PLACEHOLDER = 'Ø'
  extend ActiveSupport::Concern

  def formatted_t
    return NIL_VALUE_PLACEHOLDER if t.nil?

    t
  end
end
