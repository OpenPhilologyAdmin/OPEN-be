# frozen_string_literal: true

class ArrayOfStringsType < ActiveRecord::Type::Value
  def type
    :array_of_strings
  end

  def cast(value)
    value&.sort
  end
end
