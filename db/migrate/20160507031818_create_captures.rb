class CreateCaptures < ActiveRecord::Migration
  def change
    enable_extension "hstore"
    create_table :captures do |t|
      t.string :event
      t.integer :client_id
      t.hstore :data
      t.boolean :archived, default: false

      t.timestamps
    end
  end
end
