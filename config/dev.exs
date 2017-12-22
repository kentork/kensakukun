use Mix.Config

config :kensakukun, es_host: "localhost", es_port: "9200", api_token: System.get_env("API_TOKEN")
