class Project < ApplicationRecord
  has_many :sections, -> { order(id: :asc) }, dependent: :destroy
  has_many :tasks, dependent: :destroy

  default_scope -> { order(id: :asc) }

  enum :status, %w[standby active complete archived]

  validates :title, presence: true, length: { minimum: 3 }
  validates :description, length: { maximum: 240 }
end
