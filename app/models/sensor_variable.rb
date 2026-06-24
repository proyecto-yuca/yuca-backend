class SensorVariable < ApplicationRecord
  belongs_to :sensor
  belongs_to :variable
end
