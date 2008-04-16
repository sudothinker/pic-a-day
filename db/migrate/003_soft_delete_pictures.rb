class SoftDeletePictures < ActiveRecord::Migration
  def self.up
    add_column :pictures, :deleted_at, :timestamp
  end

  def self.down
    remove_column :pictures, :deleted_at
  end
end
