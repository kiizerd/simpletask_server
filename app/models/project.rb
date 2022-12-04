class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :title, presence: true, length: 3..32
  validates :description, length: { maximum: 240 }
end
