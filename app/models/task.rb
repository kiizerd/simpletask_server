class Task < ApplicationRecord
  belongs_to :project
  belongs_to :section

  validates :name, presence: true, length: { minimum: 3 }
  validates :details, length: { maximum: 120 }
end
