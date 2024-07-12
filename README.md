# Example Glimmer DSL GUI app using ActiveRecord

This repository was originally created to satisfy my need for a kind of
boilerplate using [Glimmer DSL](https://github.com/AndyObtiva/glimmer) with
`ActiveRecord` as an ORM over a `sqlite3` database. At that time, I couldn't
find any resources on it. Since then, [Andy
Maleh](https://github.com/AndyObtiva), [OSS Author of
Glimmer](https://github.com/AndyObtiva/glimmer), reached out to me about his
post, [Using ActiveRecord with SQLite DB in a JRuby Desktop
App](https://andymaleh.blogspot.com/2022/06/using-activerecord-with-sqlite-db-in.html).
I decided to put together a tutorial to extend this idea further, including
other migration tasks from `ActiveRecord::Tasks::DatabaseTask`, and an ability
to run `rake db:seed` using the `SeedLoader`.

If you'd like to use this repository, just follow [Setup](#setup). Otherwise,
follow the [ALTERNATIVE APPROACH](#alternative-approach).

## Setup

1. Clone repository
2. Install dependencies
    bundle install
3. Prepare database
    rake db:prepare
4. Run App
    glimmer run

## ALTERNATIVE APPROACH

**Without using this repository**, just follow along with this tutorial.

### Table of Contents

- [Install Glimmer](#install-glimmer)
- [Scaffold a Glimmer demo app](#scaffold-a-glimmer-demo-app)
- [Commit remaining scaffolding](#commit-remaining-scaffolding)
- [Add dependencies](#add-dependencies)
- [Install dependencies](#install-dependencies)
- [Add db directory](#add-db-directory)
- [Add migration for contacts table](#add-migration-for-contacts-table)
- [Add database configuration](#add-database-configuration)
- [Add a SQLite database with ActiveRecord](#add-a-sqlite-database-with-activerecord)
  - [Add shared methods for database access](#add-shared-methods-for-database-access)
  - [Add database connection](#add-database-connection)
- [Integrate DatabaseTasks with SeedLoader](#integrate-databasetasks-with-seedloader)
- [Add rake tasks for ActiveRecord migrations](#add-rake-tasks-for-activerecord-migrations)
- [Wire up ActiveRecord tasks in Rakefile](#wire-up-activerecord-tasks-in-rakefile)
- [Verify rake tasks](#verify-rake-tasks)
- [Prepare database](#prepare-database)
- [Add Contact model](#add-contact-model)
- [Add seed data](#add-seed-data)
- [Import seed data](#import-seed-data)
- [Update demo view](#update-demo-view)
- [Run demo app](#run-demo-app)
- [Troubleshooting](#troubleshooting)


### Install Glimmer

See instructions at [glimmer-dsl-libui](https://github.com/AndyObtiva/glimmer-dsl-libui?tab=readme-ov-file#setup)

### Scaffold a Glimmer demo app

    glimmer "scaffold[demo]"
    cd demo

### Commit remaining scaffolding

This step is *optional*.

Glimmer makes an initial git commit and leaves a dirty tree, so to clean it up...

    git add .
    git commit -m "Add remaining scaffolding"

### Add dependencies

*after `gem 'glimmer-dsl-libui'` line*

```ruby
# Gemfile

gem 'activerecord', '~> 7.1', '>= 7.1.3.4'
gem 'sqlite3', '~> 1.4', force_ruby_platform: true
```

### Install dependencies

    bundle install

### Add db directory

    mkdir -p db/migrate

### Add migration for contacts table

    touch db/migrate/20240708135100_create_contacts.rb

```ruby
# db/migrate/20240708135100_create_contacts.rb

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
```

### Add database configuration

    mkdir config
    touch config/database.yml

```ruby
# config/database.yml

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
```

### Add a SQLite database with ActiveRecord

#### Add shared methods for database access

    touch db/config.rb

```ruby
# db/config.rb

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
```

#### Add database connection

    touch db/connection.rb

```ruby
# db/connection.rb

require 'active_record'
require_relative './config'

include Demo::DB::Config

ActiveRecord::Base.configurations = Demo::DB::Config::yaml
ActiveRecord::Base.establish_connection(Demo::DB::Config::env.to_sym)
ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
```

### Integrate DatabaseTasks with SeedLoader

    mkdir support
    touch support/active_record_rake_tasks.rb

### Add `rake` tasks for ActiveRecord migrations
```ruby
# support/active_record_rake_tasks.rb

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
```

### Wire up ActiveRecord tasks in Rakefile
```ruby
# Rakefile

require './support/active_record_rake_tasks'
```

### Verify rake tasks

    rake -T

### Add fix for "Don't know how to build task 'environment'" error

```ruby
# Rakefile

Rake::Task.define_task(:environment)
```

### Prepare database

    rake db:prepare

### Add Contact model

    touch app/demo/model/contact.rb

```ruby
# app/demo/model/contact.rb

class Contact < ActiveRecord::Base
end
```

### Add seed data

    touch db/seeds.rb
    touch db/models.rb

```ruby
# db/models.rb

model_dir = File.expand_path('../../app/demo/model', __FILE__)
Dir.glob(File.join(model_dir, '**', '*.rb')).each { |model| require model }
```

```ruby
# db/seeds.rb

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
```

### Import seed data

     rake db:seed

### Update demo view

At the top of the file, replace the `require 'demo/model/greeting'` with:

```ruby
# app/demo/view/demo.rb

require 'demo/model/contact'
```

Inside the `before_body` block, replace `@greeting = Model::Greeting.new` with:

```ruby
@contact = Contact.first
```

Inside `def launch` method (after `margined true` line), remove the reference
to the `@greeting` `form` `entry` and add the following code to verify
ActiveRecord:

```ruby
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
```

### Run demo app

      glimmer run

### Troubleshooting

1. If you encounter a `Don't know how to build task environment` error, try adding this to the bottom of your `Rakefile`:

```ruby
# Rakefile

Rake::Task.define_task(:environment)
```

2. When an ActiveRecord::EnvironmentMismatchError exception is raised, run this from the shell:

```ruby
    rake db:environment:set ENV=development
```

3. Running `rake db:version` raises an `NameError: uninitialized constant Rails
(NameError)` exception, which can be fixed with this hack (open to other suggestions, but I gotta move on.)

```ruby
# Rakefile

class Rails
  def env
    ENV['ENV'] || 'development'
  end
end
```

#### Copyright

Copyright (c) 2024 Chip Castle. See LICENSE for further details.

<!--
[SeedLoader example](https://jeremykreutzbender.com/blog/add-active-record-rake-tasks-to-gem)
[Testing Rake task with Rspec with Rails environment](https://stackoverflow.com/questions/12686282/testing-rake-task-with-rspec-with-rails-environment) (via StackOverflow - Winston Kotzan's answer)
-->
