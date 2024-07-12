model_dir = File.expand_path('../../app/glimmer_dsl_with_active_record/model', __FILE__)
Dir.glob(File.join(model_dir, '**', '*.rb')).each { |model| require model }
