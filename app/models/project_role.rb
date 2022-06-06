# frozen_string_literal: true

class ProjectRole < ApplicationRecord
  extend Enumerize

  enumerize :role,
            in:         %i[owner],
            default:    :owner,
            predicates: true,
            scope:      :shallow

  belongs_to :user
  belongs_to :project
end
