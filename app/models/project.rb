class Project < ApplicationRecord
  has_many :sections, -> { order(id: :asc) }, dependent: :destroy
  has_many :tasks, dependent: :destroy

  validates :title, presence: true, length: 3..32
  validates :description, length: { maximum: 240 }
end
