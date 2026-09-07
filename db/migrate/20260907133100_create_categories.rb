class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :title
      t.string :slug

      t.timestamps
    end
  end
end
