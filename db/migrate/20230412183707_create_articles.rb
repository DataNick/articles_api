class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.datetime :publication_date
      t.string :category
      t.string :author
      t.string :like_counts_per_date
      t.string :slug
      t.text :body

      t.timestamps
    end
  end
end
