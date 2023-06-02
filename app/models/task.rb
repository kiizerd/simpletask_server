class Task < ApplicationRecord
  belongs_to :project
  belongs_to :section
  acts_as_list scope: :section

  # Can't have a default scope if ordering by position
  # default_scope -> { order(id: :asc) }

  enum :status, %w[standby active complete archived]

  validates :name, presence: true, length: 3..60
  validates :details, length: { maximum: 120 }
end
