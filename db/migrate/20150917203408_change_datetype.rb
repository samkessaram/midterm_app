class ChangeDatetype < ActiveRecord::Migration
  def change
    remove_column :tweets, :post_time
    add_column :tweets, :post_time, :datetime
  end
end
