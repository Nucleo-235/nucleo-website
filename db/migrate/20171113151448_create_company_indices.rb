class CreateCompanyIndices < ActiveRecord::Migration
  def change
    create_table :company_indices do |t|
      t.string :code
      t.date :reference_date
      t.string :name
      t.float :value
      t.text :description
      t.text :calculation_params

      t.timestamps null: false
    end
  end
end
