# HttpClient

**TODO: Add description**

## Runtime config

```elixir
import Config

import ConfigUtils, only: [get_env!: 3, get_env!: 2, get_env_name!: 1]


  config :http_client,
    db_repo: Repo,
    table_name: get_env!("HTTP_CLIENT_TABLE", :string, "germes.http_client"),
    pools: %{
      :default => [
        protocol: :http1,
        size: get_env!("HTTP_CLIENT_DEFAULT_POOL_SIZE", :integer, 10),
        count: get_env!("HTTP_CLIENT_DEFAULT_POOL_COUNT", :integer, 5),
        conn_max_idle_time: get_env!("HTTP_CLIENT_DEFAULT_POOL_CONN_MAX_IDLE_TIME", :integer, 10_000),
        pool_max_idle_time: get_env!("HTTP_CLIENT_DEFAULT_POOL_POOL_MAX_IDLE_TIME", :integer, 10_000),
        conn_opts: [
          timeout: get_env!("HTTP_CLIENT_DEFAULT_POOL_CONN_TIMEOUT", :integer, 30_000),
          transport_opts: [verify: :verify_none]
        ]
      ]
    }
```

### If from_db is true

#### SQL
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

#### Start application
```elixir

{:ok, pid} = HttpClient.Services.HttpClientService.start_http_client()

```



