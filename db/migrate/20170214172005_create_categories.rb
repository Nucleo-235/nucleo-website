class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :identifier, unique: true
      t.string :name
      t.string :icon_klass

      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        Category.create_translation_table!({
          :name => :string
        }, {
          :migrate_data => true
        })
      end

      dir.down do 
        Category.drop_translation_table! :migrate_data => true
      end
    end
  end
end
