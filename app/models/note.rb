class Note < ActiveRecord::Base
  belongs_to :stock
  belongs_to :earning
  validates :title, presence: true
  validates :body, presence: true
  validates :happened_at, presence: true
end