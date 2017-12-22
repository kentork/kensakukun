use Mix.Config

config :kensakukun,
  es_host: System.get_env("ES_HOST"),
  es_port: System.get_env("ES_PORT"),
  api_token: System.get_env("API_TOKEN")
