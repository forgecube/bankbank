class CreateBranches < ActiveRecord::Migration[5.2]
  def change
    create_table :branches do |t|
      t.string :ifsc, index: true, unique: true
      t.jsonb :metadata

      t.timestamps
    end
  end
end
