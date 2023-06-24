# HttpClient

**TODO: Add description**

## Runtime config

```elixir
import Config

import ConfigUtils, only: [get_env: 3, get_env: 2, get_env_name!: 1]


  config :http_client,
    db_repo: Repo,
    table_name: get_env("HTTP_CLIENT_TABLE", :string, "germes.http_client"),
    pools: %{
      :default => [
        protocol: :http1,
        size: get_env("HTTP_CLIENT_DEFAULT_POOL_SIZE", :integer, 10),
        count: get_env("HTTP_CLIENT_DEFAULT_POOL_COUNT", :integer, 5),
        conn_max_idle_time: get_env("HTTP_CLIENT_DEFAULT_POOL_CONN_MAX_IDLE_TIME", :integer, 10_000),
        pool_max_idle_time: get_env("HTTP_CLIENT_DEFAULT_POOL_POOL_MAX_IDLE_TIME", :integer, 10_000),
        conn_opts: [
          timeout: get_env("HTTP_CLIENT_DEFAULT_POOL_CONN_TIMEOUT", :integer, 30_000),
          transport_opts: [verify: :verify_none]
        ]
      ]
    }
```

### If from_db is true

#### SQL Create table

```sql
-- DROP TABLE germes.http_client;

CREATE TABLE germes.http_client (
                                    id text NOT NULL, -- URL
                                    description varchar(512) NOT NULL, -- Description
                                    config text NOT NULL, -- Config
                                    "order" int8 NOT NULL DEFAULT 0, -- Order
                                    state_id varchar(64) NOT NULL DEFAULT 'ACTIVE'::character varying, -- State id
                                    owner_id uuid NOT NULL, -- Essence id
                                    created_by uuid NOT NULL, -- Essence id
                                    updated_by uuid NOT NULL, -- Essence id
                                    created_at timestamptz NOT NULL DEFAULT now(), -- Readonly
                                    updated_at timestamptz NOT NULL DEFAULT now(), -- Readonly
                                    CONSTRAINT http_client_pk PRIMARY KEY (id)
);

-- Column comments

COMMENT ON COLUMN germes.http_client.id IS 'URL';
COMMENT ON COLUMN germes.http_client.description IS 'Description';
COMMENT ON COLUMN germes.http_client.config IS 'Config';
COMMENT ON COLUMN germes.http_client."order" IS 'Order';
COMMENT ON COLUMN germes.http_client.state_id IS 'State id';
COMMENT ON COLUMN germes.http_client.owner_id IS 'Essence id';
COMMENT ON COLUMN germes.http_client.created_by IS 'Essence id';
COMMENT ON COLUMN germes.http_client.updated_by IS 'Essence id';
COMMENT ON COLUMN germes.http_client.created_at IS 'Readonly';
COMMENT ON COLUMN germes.http_client.updated_at IS 'Readonly';
```

#### SQL Select

```sql
select
    t.id,
    t.config,
    t.order,
    t.state_id
from {#} as t
where
    t.state_id = 'ACTIVE'
order by t.order asc
```

#### Start application
```elixir

{:ok, pid} = HttpClient.Services.HttpClientService.start_http_client()

```



