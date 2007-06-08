class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.column "website_url", :text
      t.column "token",       :string
      t.column "ip_address",  :string
      t.column "created_at",  :datetime
      t.column "updated_at",  :datetime
    end
    
    add_index :links, :token
  end

  def self.down
    drop_table :links
  end
end
