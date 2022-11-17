class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :title, presence: true, length: 3..24
  validates :description, length: { maximum: 120 }
end
