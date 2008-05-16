class FbPageId < ActiveRecord::Migration
  def self.up
    add_column :pictures, :fb_page_id, :integer
  end

  def self.down
    remove_column :pictures, :fb_page_id
  end
end
