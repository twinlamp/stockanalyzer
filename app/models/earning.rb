class Earning < ActiveRecord::Base
  belongs_to :stock, dependent: :destroy
end
