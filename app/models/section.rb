class Section < ApplicationRecord
  belongs_to :project
  has_many :tasks, -> { order(position: :desc) }

  default_scope -> { order(id: :asc) }

  enum :status, %w[standby active complete archived]

  validates :name, presence: true, length: 1..21
end
