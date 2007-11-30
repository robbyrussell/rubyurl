class AddIndexOnWebsiteUrl < ActiveRecord::Migration
  def self.up
    
    execute "CREATE INDEX website_url_index ON links ((substring(website_url, 0, 200)));"
    
  end

  def self.down
    execute "DROP INDEX website_url_index;"
  end
end
