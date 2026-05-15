WITH WHALES as (

select
output_address,
sum(output_value) as total_sent,
count(*) as tx_count

from {{ ref('stg_output_transaction')}}

where output_value > 10

group by output_address
order by total_sent desc
)

select
w.output_address,
w.total_sent,
w.tx_count,
{{convert_usd('w.total_sent')}} as total_sent_usd
from WHALES w
order by total_sent desc