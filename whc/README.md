# Whc Api

An api-only Phoenix app with one added resource+controller (`Whc.Sites`) and one plug (`Whc.Plugs.Healthz`)

### Routes

- `/api/whcsites`
- `/api/whcsites/:id`
- `/healthz`

## Decisions

I decided to use Elixir+Phoenix for this to show how far I could get in a short time with unfamiliar tech. I had to read many pages of docs to extract just parts I needed for this task. I regret that I didn't find enough time to explore the test tooling for Phoenix.

I avoided rendering HTML in this app because I have little experience with website layout. However, it's clear that the whc site information is intended to be inlined into a webpage, as it contains HTML entities and locale properties for 'rtl' languages. I imagine that HTML could be added to this app with little difficulty and the api endpoint could  be extended to support features as they are built into the HTML side.

### Difficulties

Since I am managing the schema and data under `db/`, I didn't get to take advantage of Ecto's migrations and automatic making-sure-everything-is-named-the-same. I found this acceptable anyway because I was focused on deployability; having one server run migrations for one database is great for simple or local projects, but it tends to cause problems as projects grow bigger.

The postgrex connection to RDS was difficult to debug. In the end, I recognised a situation that I ran into years ago--the ssl requirements of psql and postgrex (via erlang `ssl`) don't exactly match. The right way to fix this is to have a cert file in the api image that postgrex can use to verify the RDS server identity. I currently have ecto configured to `:verify_none`--this is acceptable for the moment because the security group rules only allow traffic from know, trusted sources (my subnets)