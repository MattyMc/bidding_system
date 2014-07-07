class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.decimal :budget
      t.decimal :blocked_budget

      t.timestamps
    end
  end
end
