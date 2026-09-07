class CreateContentPages < ActiveRecord::Migration[8.0]
  def change
    create_table :content_pages do |t|
      t.string :path, null: false
      t.string :locale, null: false
      t.string :title, null: false
      t.text :description
      t.string :canonical_url
      t.string :robots
      t.string :alternate_en_url
      t.string :alternate_fr_url
      t.text :structured_data
      t.text :body_html, null: false
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    add_index :content_pages, :path, unique: true
    add_index :content_pages, [ :locale, :published ]
  end
end
