require "rails"
require "active_record"
require "database_cleaner"
require "webmock"
require "vcr"
require "pry"

require "sow"
include Sow::Helpers

Dir[File.dirname(__FILE__) + '/fixtures/models/*.rb'].each {|file| require file }

RSpec.configure do |c|
  c.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  c.before(:each) do
    DatabaseCleaner.start
  end

  c.after(:each) do
    DatabaseCleaner.clean
  end
end

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
end

# Database
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "spec/db/activerecord.db")

#User.connection.execute "DROP TABLE IF EXISTS users;"
#User.connection.execute "CREATE TABLE users (id INTEGER PRIMARY KEY , first_name VARCHAR(255), last_name VARCHAR(255));"

Post.connection.execute "DROP TABLE IF EXISTS posts;"
Post.connection.execute "CREATE TABLE posts (id INTEGER PRIMARY KEY , title VARCHAR(255), content VARCHAR(255));"

#Comment.connection.execute "DROP TABLE IF EXISTS comments;"
#Comment.connection.execute "CREATE TABLE comments (id INTEGER PRIMARY KEY , post_id INTEGER, body VARCHAR(255));"

# Helpers
#
# Setup fake `Rails.root`
def stub_rails_root
  Rails.stub(:root).and_return(Pathname.new('./spec/fixtures'))
end

# Copy and Remove Seed files around a spec
def load_seed(file)
  `cp ./spec/fixtures/seeds/#{file} ./spec/fixtures/db/seeds/development`
  yield
  `rm ./spec/fixtures/db/seeds/development/#{file}`
end
