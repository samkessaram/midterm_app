class ChangeDatetype < ActiveRecord::Migration
  def change
    remove_column :tweets, :post_time
<<<<<<< HEAD
    add_column :tweets, :post_time, :datetime
=======
    add_column :tweets, :post_time, :timestamp
>>>>>>> 47692c844b9b45d6ebd4941e461be74b3c6baf42
  end
end
