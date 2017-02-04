class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.string :type
      t.string :image
      t.string :summary
      t.text :bio

      t.timestamps null: false
    end
  end
end
