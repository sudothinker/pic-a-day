class PicturesTable < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.column :fb_user_id, :integer
      t.column :filename, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
