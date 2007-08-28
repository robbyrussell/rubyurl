class Link < ActiveRecord::Base
  TOKEN_LENGTH = 3
  
  has_many :visits
  has_many :spam_visits, :class_name => 'Visit', :conditions => ["flagged = 'spam'"]
  
  validates_presence_of :website_url, :ip_address
  validates_uniqueness_of :website_url, :token  
  validates_format_of :website_url, :with => /^(http|https):\/\/[a-z0-9]/ix, :on => :save, :message => 'needs to have http(s):// in front of it', :if => Proc.new { |p| p.website_url? }
  
  before_create :generate_token
  
  def flagged_as_spam?
    self.spam_visits.empty? ? false : true
  end
  
  def add_visit(request)
    visit = Visit.new
    visit.ip_address = request.remote_ip
    visit.save
    return visit
  end
  
  private
  
    def generate_token
      if (temp_token = random_token) and self.class.find_by_token(temp_token).nil?
        self.token = temp_token
        build_permalink
      else
        generate_token
      end
    end
    
    def build_permalink
      self.permalink = DOMAIN_NAME + self.token
    end
  
    def random_token
      characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890'
      temp_token = ''
      srand
      TOKEN_LENGTH.times do
        pos = rand(characters.length)
        temp_token += characters[pos..pos]
      end
      temp_token
    end
    
end
