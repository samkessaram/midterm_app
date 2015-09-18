class Tweet < ActiveRecord::Base

  validates :tweet, presence: true
  validate :check_for_duplicate_tweets

  def check_for_duplicate_tweets
    unless Tweet.where(tweet: tweet) == []
      errors.add(:tweet, "You have already uploaded this tweet")
  end
end
end