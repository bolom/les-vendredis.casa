class CreateJournalPosts < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :locale, null: false
      t.string :translation_key
      t.string :tag
      t.string :image_path
      t.string :image_alt
      t.text :summary
      t.text :description
      t.text :body_markdown, null: false
      t.date :published_on, null: false
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    add_index :journal_posts, [ :locale, :slug ], unique: true
    add_index :journal_posts, [ :published, :published_on ]
    add_index :journal_posts, :translation_key
  end
end
