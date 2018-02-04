class AddLevelToCompanyIndex < ActiveRecord::Migration
  def change
    add_column :company_indices, :level, :integer
    add_column :company_indices, :value_prefix, :string
    add_column :company_indices, :value_precision, :integer
  end
end
