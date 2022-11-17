class Task < ApplicationRecord
  belongs_to :project

  validates :name, presence: true, length: 3..24
  validates :details, length: { maximum: 120 }
end
