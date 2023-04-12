class CreateLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :likes do |t|
      t.integer :count
      t.datetime :date
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
