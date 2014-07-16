class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.decimal :budget, scale: 2, precision:10
      t.decimal :blocked_budget, scale: 2, precision:10 # Note: Maximum value of 99,999,999.99

      t.timestamps
    end
  end
end
