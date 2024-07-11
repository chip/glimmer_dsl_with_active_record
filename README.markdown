# Example [Glimmer DSL](https://github.com/AndyObtiva/glimmer) GUI app using ActiveRecord

## Setup

    bundle install
    glimmer run


## ALTERNATIVE APPROACH - WITHOUT using this repo

### Install Glimmer

See instructions at [glimmer-dsl-libui](https://github.com/AndyObtiva/glimmer-dsl-libui?tab=readme-ov-file#setup)

### Scaffold a Glimmer demo app

    glimmer "scaffold[demo]"

### OPTIONAL: Commit remaining scaffolding (because Glimmer makes an initial git commit and leaves a dirty tree)

      cd demo
      git add .
      git commit -m "Add remaining scaffolding"

### Add dependencies to Gemfile (after gem 'glimmer-dsl-libui' line)

      gem 'activerecord', '~> 7.1', '>= 7.1.3.4'
      gem 'sqlite3', '~> 1.4', force_ruby_platform: true

### Install dependencies

      bundle install

### Add migration runner


      mkdir db
      touch db/migrate.db


**db/migrate.db contents**

      # Source: [https://andymaleh.blogspot.com/2022/06/using-activerecord-with-sqlite-db-in.html](https://andymaleh.blogspot.com/2022/06/using-activerecord-with-sqlite-db-in.html)
      # [Thank you Andy!](https://github.com/AndyObtiva))
      migrate_dir = File.expand_path('../migrate', __FILE__)
      Dir.glob(File.join(migrate_dir, '**', '*.rb')).each {|migration| require migration}

      ActiveRecord::Migration[7.1].descendants.each do |migration| 
        begin
          migration.migrate(:up)
        rescue => e
          raise e unless e.full_message.match(/table "[^"]+" already exists/)
        end
      end

### Add an ActiveRecord migration for the contacts database table

    mkdir db/migrate
    touch db/migrate/20240708135100_create_contacts.rb

**Contents of migration file**

    require 'active_record'

    class CreateContacts < ActiveRecord::Migration[7.1]
      def change
        create_table :contacts do |t|
          t.string     :first_name
          t.string     :last_name
          t.string     :email
          t.string     :phone
          t.string     :street
          t.string     :city
          t.string     :state_or_province
          t.string     :zip_or_postal_code
          t.string     :country
        end
      end
    end

### Add database.yml

    mkdir config
    touch config/database.yml

**Contents of database.yml**

    default: &default
      adapter: sqlite3
      pool: 5
      timeout: 5000

    development:
      <<: *default
      database: db/demo.sqlite3

    test:
      <<: *default
      database: db/test.sqlite3

### Add a SQLite database with ActiveRecord

    touch db/config.rb
    touch db/connection.rb

**Contents of db config file**

    class Demo
      module DB
        module Config
          def root
            File.expand_path('../..', __FILE__)
          end

          def file
            File.join(root, "config/database.yml")
          end

          def yaml
            # aliases: true fixes Psych::AliasesNotEnabled exception
            YAML.load_file(file, aliases: true)
          end

          def env
            ENV['ENV'] || 'development'
          end
        end
      end
    end

**Contents of db connection file**

    require 'active_record'
    require_relative './config'

    include Demo::DB::Config

    ActiveRecord::Base.configurations = Demo::DB::Config::yaml
    ActiveRecord::Base.establish_connection(Demo::DB::Config::env.to_sym)
    ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)

### Create file that contains rake tasks for ActiveRecord

      mkdir support
      touch support/active_record_rake_tasks.rb

### Add rake tasks for ActiveRecord to support/active_record_rake_tasks.rb

      # Source for SeedLoader: https://jeremykreutzbender.com/blog/add-active-record-rake-tasks-to-gem
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

      require_relative "../db/migrate"
      load 'active_record/railties/databases.rake'

### Wire up ActiveRecord tasks in Rakefile

      # Source: https://jeremykreutzbender.com/blog/add-active-record-rake-tasks-to-gem
      require './support/active_record_rake_tasks'

### Verify tasks load

      # rake --tasks or rake -T
      rake -T

### Add fix for "Don't know how to build task 'environment'" error

**Contents of Rakefile**

      # Source: https://stackoverflow.com/questions/12686282/testing-rake-task-with-rspec-with-rails-environment
      Rake::Task.define_task(:environment)

# TODO ### Run migrations
### Setup database

# TODO rake db:environment:set ENV=development
# TODO rake db:setup
      rake db:migrate

### Add model(s)

      touch app/demo/model/contact.rb

**Contents of app/demo/model/contact.rb**

      class Contact < ActiveRecord::Base
      end

### Add seed data

      touch db/seeds.rb
# TODO touch db/models.rb

  **Contents of db/models.rb**

# TODO      model_dir = File.expand_path('../../app/demo/model', __FILE__)
# TODO      Dir.glob(File.join(model_dir, '**', '*.rb')).each { |model| require model }

**Contents of db/seeds.rb**

      require 'active_record'
      require_relative './connection'
      require_relative "./models"

      Contact.create(first_name: 'Chip',
                     last_name: 'Castle',
                     email: 'chip@chipcastle.com',
                     phone: '555-555-5555',
                     street: 'Any street',
                     city: 'Inlet Beach',
                     state_or_province: 'FL',
                     zip_or_postal_code: '55555',
                     country: 'US')

# TODO ### Import seed data

# TODO      rake db:seed

### Update view

Edit **app/demo/view/demo.rb**. Inside `def launch` method (after `margined
true` line) add the following code to verify ActiveRecord:

          vertical_box {
            form {
              stretchy false

              entry {
                label 'First name'
                text <=> [@contact, :first_name]
              }
              entry {
                label 'Last name'
                text <=> [@contact, :last_name]
              }
              entry {
                label 'Email'
                text <=> [@contact, :email]
              }
              entry {
                label 'Phone'
                text <=> [@contact, :phone]
              }
              entry {
                label 'Street address'
                text <=> [@contact, :street]
              }
              entry {
                label 'City'
                text <=> [@contact, :city]
              }
              entry {
                label 'State/Province'
                text <=> [@contact, :state_or_province]
              }
              entry {
                label 'Zip/Postal code'
                text <=> [@contact, :zip_or_postal_code]
              }
              entry {
                label 'Country'
                text <=> [@contact, :country]
              }
            }
          }

### Run demo app

      glimmer run

Copyright
---------

Copyright (c) 2024 Chip Castle. See LICENSE for further details.
