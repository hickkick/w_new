require "./config/initializers/database"
require "sequel/extensions/migration"
require "fileutils"

namespace :db do
  # Шлях до папки з міграціями
  MIGRATIONS_DIR = "db/migrations"

  desc "Запустити міграції"
  task :migrate do
    Sequel::Migrator.run(DB, MIGRATIONS_DIR)
    puts "✅ Міграції виконано."
  end

  desc "Відкотитися на 1 крок назад"
  task :rollback do
    # Рахуємо поточну версію і віднімаємо 1
    current_version = Sequel::Migrator.migratables(DB, MIGRATIONS_DIR).keys.max || 0
    target = current_version > 0 ? current_version - 1 : 0
    Sequel::Migrator.run(DB, MIGRATIONS_DIR, target: target)
    puts "⏪ Відкочено до версії #{target}."
  end

  desc "Повний ресет бази (для SQLite)"
  task :reset do
    # Дістаємо шлях до файлу прямо з налаштувань Sequel
    db_path = DB.opts[:database]
    if db_path && File.exist?(db_path)
      DB.disconnect # Закриваємо з'єднання перед видаленням
      File.delete(db_path)
      puts "🗑 Файл #{db_path} видалено."
    end
    # Наново підключаємося (Sequel автоматично створить файл при зверненні)
    Rake::Task["db:migrate"].invoke
  end

  desc "Створити нову міграцію (шаблон 001, 002...) та модель"
  task :new_migration, [:name] do |t, args|
    name = args[:name] || "migration"

    # Створюємо міграцію
    FileUtils.mkdir_p(MIGRATIONS_DIR)
    last_migration = Dir["#{MIGRATIONS_DIR}/*.rb"].map { |f| File.basename(f).to_i }.max || 0
    new_number = (last_migration + 1).to_s.rjust(3, "0")
    migration_filename = "#{MIGRATIONS_DIR}/#{new_number}_#{name}.rb"

    File.open(migration_filename, "w") do |f|
      f.write <<~RUBY
                Sequel.migration do
                  change do
                    # create_table :#{name.gsub("create_", "").gsub("add_", "")} do
                    #   primary_key :id
                    #   String :name, null: false
                    #   DateTime :created_at
                    #   DateTime :updated_at
                    # end
                  end
                end
              RUBY
    end
    puts "📝 Створено міграцію: #{migration_filename}"

    # Створюємо модель
    FileUtils.mkdir_p("models")
    # Перетворюємо назву на CamelCase для класу
    # create_users → User, add_posts → Post
    model_name = name.gsub(/^(create|add)_/, "").split("_").map(&:capitalize).join
    model_name = model_name.chomp("s") # users → User (прибираємо множину)

    model_filename = "models/#{model_name.downcase}.rb"

    unless File.exist?(model_filename)
      File.open(model_filename, "w") do |f|
        f.write <<~RUBY
                  class #{model_name} < Sequel::Model
                    # plugin :timestamps, update_on_create: true
                    # plugin :validation_helpers
                    
                    # def validate
                    #   super
                    #   validates_presence [:name]
                    # end
                  end
                RUBY
      end
      puts "📦 Створено модель: #{model_filename}"
    else
      puts "⚠️  Модель #{model_filename} вже існує, пропускаємо."
    end
  end
end

desc "Запустити консоль проекту (Pry або IRB)"
task :console do
  # Намагаємося запустити Pry, якщо немає — IRB
  begin
    require "pry"
    exec "pry -r ./app.rb"
  rescue LoadError
    exec "irb -r ./app.rb"
  end
end

namespace :server do
  desc "запуск сервера з авторелоадом"
  task :r do
    puts "🚀 Запуск сервера через rackup..."
    exec "bundle exec rackup -o 0.0.0.0 -p 4567"
  end

  desc "Повний ресет бази та запуск сервера"
  task :rrr do
    Rake::Task["db:reset"].invoke

    puts "🚀 Запуск сервера ..."

    Rake::Task["server:r"].invoke
  end
end

# Завдання за замовчуванням: показати список команд
task :default do
  system "rake -T"
end
