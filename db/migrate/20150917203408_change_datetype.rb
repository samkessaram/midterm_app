class ChangeDatetype < ActiveRecord::Migration
  def change
    change_column :tweets, :post_time, :timestamp
  end
end
