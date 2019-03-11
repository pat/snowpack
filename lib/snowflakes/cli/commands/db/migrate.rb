require "hanami/cli"
require "snowflakes/cli/command"

module Snowflakes
  class CLI < Hanami::CLI
    module Commands
      module DB
        class Migrate < Command
          desc "Migrates database"

          option :target, desc: "Target migration number", aliases: ["-t"]

          def call(target: nil, **)
            prepare

            measure "database #{database_name} migrated" do
              if target
                gateway.run_migrations(target: target)
              else
                gateway.run_migrations
              end
            end
          end

          private

          def prepare
            application.boot :persistence
          end

          def gateway
            application.container["persistence.config"].gateways[:default]
          end

          def database_name
            gateway.connection.url.split("/").last
          end
        end
      end
    end

    register "db migrate", Commands::DB::Migrate
  end
end
