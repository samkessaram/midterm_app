class AddUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :token
      t.string :secret
    end
  end
end
