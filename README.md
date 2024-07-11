# Example [Glimmer DSL](https://github.com/AndyObtiva/glimmer)[^1] GUI app using ActiveRecord

## Setup

    bundle install
    glimmer run


## ALTERNATIVE APPROACH

**Without using this repository**, just follow along with this tutorial.

### Table of Contents


<!--
- [Install Glimmer](#install-glimmer)
- [Scaffold a Glimmer demo app](#scaffold-a-glimmer-demo-app)
- [Commit remaining scaffolding](#commit-remaining-scaffolding)
- [Add dependencies to Gemfile](#add-dependencies)
- [Install dependencies](#install-dependencies)
- [Add db directory](#add-db-directory)

- XXXXXX [Add migration runner](#add-migration-runner)
- [Add an ActiveRecord migration for the contacts database table](#add-an-active-record-migration-for-the-contacts-database-table)
- [Add database.yml](add-database-yml)
- [Add a SQLite database with ActiveRecord](add-a-sqlite-database-with-activerecord)
  - [Add database configuration](#add-db-config)
  - [Add database connection](#add-db-connection)
- [Create file that contains rake tasks for ActiveRecord](#create-ar-rake-tasks-file)
- [Add rake tasks for ActiveRecord to support file](add-rake-tasks-for-ar) [^4]
- [Wire up ActiveRecord tasks in Rakefile](#wire-up-ar-tasks)
- [Verify tasks load](#verify-rake-tasks)
- [Add fix for "Don't know how to build task 'environment'" error](#add-env-fix) [^5]
- [Prepare database](#prepare-db)
- [Add Contact model](#add-contact-model)
- [Add seed data](#add-seed-data)
- [Import seed data](#import-seed-data)
- [Update demo view](#update-demo-view)
- [Run demo app](#run-demo)
- [Troubleshooting](#troubleshooting)
- [Sources (footnotes)](#sources)
-->


### Install Glimmer[^2] <a id="install-glimmer" name="install-glimmer"></a>

See instructions at [glimmer-dsl-libui](https://github.com/AndyObtiva/glimmer-dsl-libui?tab=readme-ov-file#setup)

### Scaffold a Glimmer demo app <a id="scaffold-a-glimmer-demo-app"></a>

    glimmer "scaffold[demo]"
	cd demo

### Commit remaining scaffolding

This step is *optional*.

Glimmer makes an initial git commit and leaves a dirty tree, so to clean it up...

    git add .
    git commit -m "Add remaining scaffolding"

### Add dependencies to Gemfile

*after `gem 'glimmer-dsl-libui'` line*

```ruby
# Gemfile

gem 'activerecord', '~> 7.1', '>= 7.1.3.4'
gem 'sqlite3', '~> 1.4', force_ruby_platform: true
```

### Install dependencies

    bundle install

### Add db directory

    mkdir db

<!--

### Add migration runner

    touch db/migrate.rb

# TODO **db/migrate.db contents**[^3]

```ruby
# db/migrate.db contents

migrate_dir = File.expand_path('../migrate', __FILE__)
Dir.glob(File.join(migrate_dir, '**', '*.rb')).each {|migration| require migration}

ActiveRecord::Migration[7.1].descendants.each do |migration| 
  begin
    migration.migrate(:up)
  rescue => e
    raise e unless e.full_message.match(/table "[^"]+" already exists/)
  end
end
```
-->

### Add an ActiveRecord migration for the contacts database table

    mkdir db/migrate
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

### Add database.yml

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

#### Add database configuration

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

### Create file that contains rake tasks for ActiveRecord

    mkdir support
    touch support/active_record_rake_tasks.rb

### Add `rake` tasks for ActiveRecord[^4]

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

### Wire up ActiveRecord tasks

```ruby
# Rakefile

require './support/active_record_rake_tasks'
```

### Verify tasks load

    rake -T

### Add fix for "Don't know how to build task 'environment'" error[^5]

```ruby
# Rakefile

Rake::Task.define_task(:environment)
```

### Prepare database

    rake db:prepare

### Add Contact model

    touch app/demo/model/contact.rb

**Contents of app/demo/model/contact.rb**

```ruby
class Contact < ActiveRecord::Base
end
```

### Add seed data

    touch db/seeds.rb
    touch db/models.rb

  **Contents of db/models.rb**

```ruby
model_dir = File.expand_path('../../app/demo/model', __FILE__)
Dir.glob(File.join(model_dir, '**', '*.rb')).each { |model| require model }
```

  **Contents of db/seeds.rb**
```ruby
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

Edit **app/demo/view/demo.rb**.

At the top of the file, replace the `require 'demo/model/greeting'` with:

```ruby
require 'demo/model/contact'
```

Inside the `before_body` block, replace `@greeting = Model::Greeting.new` with:

```ruby
@contact = Contact.first
```

Inside `def launch` method (after `margined
true` line), remove the reference to the `@greeting` `form` `entry` and add the following code to verify ActiveRecord:
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

#### ActiveRecord::EnvironmentMismatchError: You are attempting to modify a database that was last run in `development` environment. (ActiveRecord::EnvironmentMismatchError)

    rake db:environment:set ENV=development

#### rake db:version

Running `rake db:version` raises an `NameError: uninitialized constant Rails (NameError)` exception, which can be fixed by adding the following to the `Rakefile`:

```ruby 
class Rails
  def env
    ENV['ENV'] || 'development'
  end
end
```

Copyright
---------

Copyright (c) 2024 Chip Castle. See LICENSE for further details.


### Sources (footnotes)

[^1]: [Thank you Andy for Glimmer!](https://github.com/AndyObtiva)
[^2]: [glimmer-dsl-libui on GitHub](https://github.com/AndyObtiva/glimmer-dsl-libui?tab=readme-ov-file#setup)
[^3]: [Using ActiveRecord with SQLite DB in a JRuby Desktop App](https://andymaleh.blogspot.com/2022/06/using-activerecord-with-sqlite-db-in.html).
[^4]: [SeedLoader example](https://jeremykreutzbender.com/blog/add-active-record-rake-tasks-to-gem)
[^5]: [Testing Rake task with Rspec with Rails environment](https://stackoverflow.com/questions/12686282/testing-rake-task-with-rspec-with-rails-environment) (via StackOverflow - Winston Kotzan's answer)
