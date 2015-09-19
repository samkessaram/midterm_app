class Tweet < ActiveRecord::Base
    validates :tweet, presence: true
    validates :post_time, presence: true
    validate :check_for_duplicate_tweets

    def check_for_duplicate_tweets
      if  Tweet.where(tweet: tweet) == []
      else
        errors.add(:Tweet, "can't be a duplicate!")
      end
    end
end