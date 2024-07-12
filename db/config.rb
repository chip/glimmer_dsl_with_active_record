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
