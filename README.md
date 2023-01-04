# HttpClient

**TODO: Add description**

## Runtime config

```elixir
import Config

import ConfigUtils, only: [get_env!: 3, get_env!: 2, get_env_name!: 1]

in_container = in_container!()

if in_container do
  config :logger,
    handle_otp_reports: true,
    backends: [
      :console
    ]

  config :logger,
         :console,
         level: get_env!(get_env_name!("CONSOLE_LOG_LEVEL"), :atom, :info),
         format: get_env!(get_env_name!("LOG_FORMAT"), :string, "[$date] [$time] [$level] [$node] [$metadata] [$levelpad] [$message]\n"),
         metadata: :all
else
  config :logger,
    handle_otp_reports: true,
    backends: [
      :console,
      {LoggerFileBackend, :info_log},
      {LoggerFileBackend, :error_log}
    ]

  config :logger,
         :console,
         level: get_env!(get_env_name!("CONSOLE_LOG_LEVEL"), :atom, :info),
         format: get_env!(get_env_name!("LOG_FORMAT"), :string, "[$date] [$time] [$level] [$node] [$metadata] [$levelpad] [$message]\n"),
         metadata: :all

  config :logger,
         :info_log,
         level: :info,
         path: get_env!(get_env_name!("LOG_PATH"), :string, "log") <> "/#{Node.self()}/info.log",
         format: get_env!(get_env_name!("LOG_FORMAT"), :string, "[$date] [$time] [$level] [$node] [$metadata] [$levelpad] [$message]\n"),
         metadata: :all

  config :logger,
         :error_log,
         level: :error,
         path: get_env!(get_env_name!("LOG_PATH"), :string, "log") <> "/#{Node.self()}/error.log",
         format: get_env!(get_env_name!("LOG_FORMAT"), :string, "[$date] [$time] [$level] [$node] [$metadata] [$levelpad] [$message]\n"),
         metadata: :all
end


if config_env() in [:dev] do
end

if config_env() in [:prod] do
end

  config :http_client,
    from_db: false,
    table_name: "germes.transport",
    pools: %{
      :default => [
        protocol: :http1,
        size: get_env!(get_env_name!("HTTP_CLIENT_DEFAULT_POOL_SIZE"), :integer, 10),
        count: get_env!(get_env_name!("HTTP_CLIENT_DEFAULT_POOL_COUNT"), :integer, 5),
        conn_max_idle_time: get_env!(get_env_name!("HTTP_CLIENT_DEFAULT_POOL_CONN_MAX_IDLE_TIME"), :integer, 10_000),
        pool_max_idle_time: get_env!(get_env_name!("HTTP_CLIENT_DEFAULT_POOL_POOL_MAX_IDLE_TIME"), :integer, 10_000),
        conn_opts: [
          timeout: get_env!(get_env_name!("HTTP_CLIENT_DEFAULT_POOL_CONN_TIMEOUT"), :integer, 30_000),
          transport_opts: [verify: :verify_none]
        ]
      ]
    }
```

### If from_db is true
```sql
CREATE TABLE transport (
	url text NOT NULL, -- URL
	config text NOT NULL, -- Config in elexir code
	state_id varchar(64) NOT NULL -- State id: active, inactive
    -- Any other fields
);

COMMENT ON COLUMN transport.url IS 'URL';
COMMENT ON COLUMN transport.config IS 'Config';
COMMENT ON COLUMN transport.state_id IS 'State id';

select t.url, t.config from transport as t where t.state_id = 'active'

```



