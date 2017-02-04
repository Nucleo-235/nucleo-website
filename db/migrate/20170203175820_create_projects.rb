class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :type
      t.string :image
      t.string :summary

      t.timestamps null: false
    end
  end
end
