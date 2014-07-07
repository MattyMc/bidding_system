class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.decimal :budget, precision: 2
      t.decimal :blocked_budget, precision: 2

      t.timestamps
    end
  end
end
