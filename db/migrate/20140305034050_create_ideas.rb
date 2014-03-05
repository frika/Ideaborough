class CreateIdeas < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.text :content
      t.references :user, index: true

      t.timestamps
    end
  end
end
