require 'rom'
require 'rom/sql/rake_task'
require 'dotenv/tasks'
require 'dotenv'
require 'open3'
require 'uri'

ENV['HANAMI_ENV'] ||= 'development'

if ENV['HANAMI_ENV'] == 'development' || ENV['HANAMI_ENV'] == 'test'
  Dotenv.load(".env.#{ENV['HANAMI_ENV']}.local")
  Dotenv.load(".env.#{ENV['HANAMI_ENV']}")
end

Dotenv.load(".env-#{ENV['PARTNER_PLATFORM']}.#{ENV['HANAMI_ENV']}.local")
Dotenv.load(".env-#{ENV['PARTNER_PLATFORM']}.#{ENV['HANAMI_ENV']}")
Dotenv.load('.env-common')

class MigrationError < StandardError
end

class DbTaskHelper
  class << self

    HOST         = 'PGHOST'.freeze
    PORT         = 'PGPORT'.freeze
    USER         = 'PGUSER'.freeze
    PASSWORD     = 'PGPASSWORD'.freeze
    DATABASE_URL = 'DATABASE_URL'.freeze

    def set_environment_variables
      ENV[HOST]     = host      unless host.nil?
      ENV[PORT]     = port.to_s unless port.nil?
      ENV[PASSWORD] = password  unless password.nil?
      ENV[USER]     = username  unless username.nil?
    end

    def call_db_command(command)
      Open3.popen3(*command_with_credentials(command)) do |_stdin, _stdout, stderr, wait_thr|
        raise MigrationError, stderr.read unless wait_thr.value.success? # wait_thr.value is the exit status
      end
    rescue SystemCallError => e
      raise MigrationError, e.message
    end

    private

      def database_url
        @database_url ||= URI.parse(ENV[DATABASE_URL])
      end

      def host
        database_url.host
      end

      def port
        database_url.port
      end

      def username
        database_url.user
      end

      def password
        database_url.password
      end

      def database
        database_url.path[1..]
      end

      def connection
        Sequel.connect(database_url.to_s)
      end

      def command_with_credentials(command)
        result = [escape(command)]
        result << "--host=#{host}" if host
        result << "--port=#{port}" if port
        result << "--username=#{username}" if username
        result << '--no-password'
        result << database

        result.compact
      end

      def escape(string)
        Shellwords.escape(string) unless string.nil?
      end
  end
end

# Copied from ROM
namespace :db do
  task :create do
    DbTaskHelper.set_environment_variables

    begin
      DbTaskHelper.call_db_command('createdb')
    rescue MigrationError => e
      puts e.message
    end
  end

  task :setup do
    configuration = ROM::Configuration.new(:sql, ENV.fetch('DATABASE_URL'))
    ROM::SQL::RakeSupport.env = ROM.container(configuration)
  end

  desc 'Create database and run migrations'
  task prepare: [:create, :migrate]

  desc 'Drop database'
  task :drop do
    DbTaskHelper.set_environment_variables

    DbTaskHelper.call_db_command('dropdb')
  end

  desc 'Rollback migration (options [step])'
  task :rollback, [:step] => :environment do |_, args|
    Rake::Task['db:setup'].invoke

    step = (args[:step] || 1).to_i

    # Reference: https://github.com/jeremyevans/sequel/blob/d9104d2cf0611f749a16fe93c4171a1147dfd4b2/lib/sequel/extensions/migration.rb#L598
    if step >= 20000101
      ROM::SQL::RakeSupport.run_migrations(target: step)
      puts "<= db:rollback version=[#{step}] executed"
      exit
    end

    gateway = ROM::SQL::RakeSupport.env.gateways[:default]
    unless gateway.dataset?(:schema_migrations)
      puts '<= db:rollback failed due to missing schema_migrations'
      exit 0
    end

    schema_migrations = gateway.dataset(:schema_migrations).all
    versions = schema_migrations
               .sort_by { |s| s[:filename] }
               .reverse
               .map { |s| s[:filename].split('_').first }

    versions.shift(step)
    target = versions.first.to_i
    ROM::SQL::RakeSupport.run_migrations(target:)

    puts "<= db:rollback version=[#{target}] executed"
  end

  task seed: :environment do
    book_repo = Bookshelf::Repositories::BookRepository.new
    break if book_repo.all.size >= 10

    10.times do
      book_repo.create(
        title: Faker::Book.title,
        author: Faker::Book.author
      )
    end
  end
end
