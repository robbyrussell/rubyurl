class CreateVisits < ActiveRecord::Migration
  def self.up
    create_table :visits do |t|
      t.column :link_id, :integer
      t.column :referral_link, :text
      t.column :flagged, :string 
      t.column :ip_address, :text
      t.column :created_at, :timestamp
    end
    
    add_index :visits, :link_id
    add_index :visits, :flagged
  end

  def self.down
    drop_table :visits
  end
end
