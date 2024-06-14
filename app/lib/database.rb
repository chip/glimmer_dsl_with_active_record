require 'active_record'
require 'logger'
 
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/development.sqlite3'
)
 
ActiveRecord::Base.logger = Logger.new(STDOUT)
