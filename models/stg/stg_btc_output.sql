{{config (materialized = 'incremental',
          incremental_strategy = 'append')}}
with flatten_column as (
select
tx.HASH_KEY
,tx.BLOCK_NUMBER
,tx.BLOCK_TIMESTAMP
,tx.IS_COINBASE
,f.value:address::STRING as output_address
,f.value:value::float as output_value
from {{ref('stg_btc')}} tx,
LATERAL FLATTEN (input => outputs) f
where f.value:address is not null

{%if is_incremental()%}
and BLOCK_TIMESTAMP >= (select max(BLOCK_TIMESTAMP) from {{this}})
{%endif%}
)

select 
HASH_KEY,
BLOCK_NUMBER,
BLOCK_TIMESTAMP,
IS_COINBASE,
output_address,
output_value
from flatten_column

