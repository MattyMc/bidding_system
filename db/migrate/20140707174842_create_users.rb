class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.decimal :budget, scale: 2, precision:10
      t.decimal :blocked_budget, scale: 2, precision:10

      t.timestamps
    end
  end
end
