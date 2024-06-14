# Delete this example model and replace with your own model
class GlimmerDslWithActiveRecord
  module Model
    class Greeting < ActiveRecord::Base
      validates :content, presence: true
    end
  end
end
