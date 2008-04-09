class PictureColumns < ActiveRecord::Migration
  def self.up
    add_column :pictures, :size, :integer
    add_column :pictures, :content_type, :string
    add_column :pictures, :height, :integer
    add_column :pictures, :width, :integer
    add_column :pictures, :parent_id, :integer
    add_column :pictures, :thumbnail, :string
  end

  def self.down
    remove_column :pictures, :size
    remove_column :pictures, :content_type
    remove_column :pictures, :height
    remove_column :pictures, :width
    remove_column :pictures, :parent_id
    remove_column :pictures, :thumbnail
  end
end
