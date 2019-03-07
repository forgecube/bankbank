class Branch < ApplicationRecord
  validates_uniqueness_of :ifsc
end
