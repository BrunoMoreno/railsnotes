class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.string :title
      t.text :content
      t.boolean :is_public
      t.references :category, null: true, foreign_key: true

      t.timestamps
    end
  end
end
