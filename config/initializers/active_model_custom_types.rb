# frozen_string_literal: true

require Rails.root.join('app/types/array_of_strings_type.rb')

ActiveModel::Type.register(:array_of_strings, ArrayOfStringsType)
