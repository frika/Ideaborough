class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :commentable_type
      t.integer :commentable_id
      t.integer :creator_id
      t.text :content

      t.timestamps
    end

    add_index :comments, [:commentable_id, :commentable_type]
    add_index :comments, :creator_id
  end
end
