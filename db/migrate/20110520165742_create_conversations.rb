class CreateConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t|
      t.text :content
      t.integer :order
      t.boolean :done

      t.timestamps
    end
  end

  def self.down
    drop_table :todos
  end
end
