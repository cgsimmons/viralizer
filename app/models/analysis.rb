# Tableless model for search form validations
class Analysis
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :min_upvotes, :subreddit

  validates :min_upvotes,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }
  validates :subreddit, presence: true

  class << self
    def all
      []
    end
  end

  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v)
    end
  end

  def persisted?
    false
  end
end
