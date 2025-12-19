require "./db/database"
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

  desc "Створити нову міграцію (шаблон 001, 002...)"
  task :new_migration, [:name] do |t, args|
    name = args[:name] || "migration"
    FileUtils.mkdir_p(MIGRATIONS_DIR)

    # Знаходимо останній номер у папці
    last_migration = Dir["#{MIGRATIONS_DIR}/*.rb"].map { |f| File.basename(f).to_i }.max || 0
    new_number = (last_migration + 1).to_s.rjust(3, "0") # робить 001, 002...

    filename = "#{MIGRATIONS_DIR}/#{new_number}_#{name}.rb"

    File.open(filename, "w") do |f|
      f.write <<~RUBY
                Sequel.migration do
                  change do
                    # create_table :table do ... end
                  end
                end
              RUBY
    end
    puts "📝 Створено: #{filename}"
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
  desc "Повний ресет бази та запуск сервера"
  task :reset_and_run do
    # 1. Викликаємо вже існуючу таску ресету бази
    Rake::Task["db:reset"].invoke

    puts "🚀 Запуск сервера Sinatra..."

    # 2. Запускаємо сервер
    # Використовуємо 'ruby app.rb' або 'rackup' залежно від того, як ви запускаєте
    # Флаг -O дозволяє передавати параметри, якщо треба
    exec "ruby app.rb"
  end
end

# Завдання за замовчуванням: показати список команд
task :default do
  system "rake -T"
end
