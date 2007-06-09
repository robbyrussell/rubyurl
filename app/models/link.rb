class Link < ActiveRecord::Base
  TOKEN_LENGTH = 3
  
  validates_presence_of :website_url, :ip_address
  validates_uniqueness_of :website_url, :token
  
  before_save :generate_token
  
  private
  
    def generate_token  
      temp_token = random_token
      if self.class.find_by_token(temp_token).nil?
        self.token = temp_token
        return true
      else
        generate_token
      end
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
