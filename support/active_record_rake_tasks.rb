require_relative '../db/connection'

include ActiveRecord::Tasks

root = Demo::DB::Config::root

DatabaseTasks.root = root
DatabaseTasks.db_dir = File.join(root, 'db')
DatabaseTasks.migrations_paths = [File.join(root, 'db/migrate')]
DatabaseTasks.database_configuration = Demo::DB::Config::yaml

# The SeedLoader is Optional, if you don't want/need seeds you can skip setting it
class SeedLoader
  def initialize(seed_file)
    @seed_file = seed_file
  end

  def load_seed
    load @seed_file if File.exist?(@seed_file)
  end
end

DatabaseTasks.seed_loader = SeedLoader.new(File.join(root, 'db/seeds.rb'))
DatabaseTasks.env = Demo::DB::Config::env

load 'active_record/railties/databases.rake'
