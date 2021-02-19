namespace :deploy do
    desc 'Executando testes antes de fazer o deploy'
    task :test_suite do
      on roles(:main) do
        within current_path do
          with rails_env: fetch(:rails_env) do
            execute :rake, 'test'
          end
        end
      end
    end
  end