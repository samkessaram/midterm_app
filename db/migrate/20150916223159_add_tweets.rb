class AddTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :user_id
      t.string :tweet
      t.string :post_time
      t.datetime :created_at
    end
  end
end
