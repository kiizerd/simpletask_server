class Task < ApplicationRecord
  belongs_to :project
  belongs_to :section

  default_scope -> { order(id: :asc) }

  enum :status, %w[standby active complete archived]

  validates :name, presence: true, length: 3..60
  validates :details, length: { maximum: 120 }
end
