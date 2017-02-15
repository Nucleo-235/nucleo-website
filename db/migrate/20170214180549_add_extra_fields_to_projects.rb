class AddExtraFieldsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :thumb_image, :string
    add_column :projects, :sort_order, :integer
  end
end
