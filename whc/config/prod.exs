import Config

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

config :whc, Whc.Repo,
  ssl: true,
  ssl_opts: [verify: :verify_none]
