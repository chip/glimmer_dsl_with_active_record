require 'active_record'
require_relative './config'

include Demo::DB::Config

ActiveRecord::Base.configurations = Demo::DB::Config::yaml
ActiveRecord::Base.establish_connection(Demo::DB::Config::env.to_sym)
ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
