class TranslatePeople < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        Person.create_translation_table!({
          :summary => :string,
          :bio => :text
        }, {
          :migrate_data => true
        })
      end

      dir.down do 
        Person.drop_translation_table! :migrate_data => true
      end
    end
  end
end
