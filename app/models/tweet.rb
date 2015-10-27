class Tweet < ActiveRecord::Base
    validates :tweet, presence: true
    validates :post_time, presence: true
    validate :check_for_duplicate_tweets
    validate :post_time_is_in_future, if: :post_time

    def check_for_duplicate_tweets
      if  Tweet.where(tweet: tweet) == []
      else
        errors.add(:Tweet, "can't be a duplicate!")
      end
    end

    def post_time_is_in_future
      if post_time && post_time > Time.now
      else
        errors.add(:Tweet, "must be in the future!")
      end
    end
end