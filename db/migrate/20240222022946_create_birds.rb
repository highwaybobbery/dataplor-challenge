class CreateBirds < ActiveRecord::Migration[7.1]
  def change
    create_table :birds do |t|
      t.string :name
      t.references :node, null: false, foreign_key: true

      t.timestamps
    end
  end
end
