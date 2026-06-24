-- ============================================================
-- Tablas de Verdad 2025 — Reporting (eventos anónimos) + Catálogo
-- Prefijo tv_ para aislar de la app "mapingo".
-- ============================================================

-- ── 1. Stream de eventos anónimos (reporting) ──────────────────────────────
create table if not exists public.tv_events (
  id           bigint generated always as identity primary key,
  device_id    uuid        not null,
  event_name   text        not null,
  expression   text,
  locale       text,
  is_pro       boolean     not null default false,
  platform     text,
  app_version  text,
  params       jsonb       not null default '{}'::jsonb,
  created_at   timestamptz not null default now()
);

comment on table public.tv_events is 'Eventos anónimos de la app Tablas de Verdad para reporting. Inserción anónima; lectura solo service_role.';

create index if not exists tv_events_event_name_idx on public.tv_events (event_name);
create index if not exists tv_events_created_at_idx  on public.tv_events (created_at desc);
create index if not exists tv_events_device_id_idx   on public.tv_events (device_id);
create index if not exists tv_events_expression_idx  on public.tv_events (expression) where expression is not null;

alter table public.tv_events enable row level security;

create policy tv_events_anon_insert
  on public.tv_events for insert
  to anon, authenticated
  with check (true);

-- ── 2. Catálogo de expresiones destacadas (ejemplos / del día / populares) ──
create table if not exists public.tv_featured_expressions (
  id            bigint generated always as identity primary key,
  expression    text        not null,
  kind          text        not null default 'example'
                  check (kind in ('example','daily','popular')),
  category      text        check (category in ('tautology','contradiction','contingency')),
  difficulty    smallint    check (difficulty between 1 and 5),
  locale        text,
  featured_date date,
  sort_order    int         not null default 0,
  active        boolean     not null default true,
  created_at    timestamptz not null default now()
);

comment on table public.tv_featured_expressions is 'Catálogo curado de expresiones para sugerencias, ejemplos y expresión del día. Lectura anónima (solo active).';

create index if not exists tv_featured_kind_idx on public.tv_featured_expressions (kind, active);
create unique index if not exists tv_featured_daily_idx
  on public.tv_featured_expressions (featured_date, coalesce(locale,'*'))
  where kind = 'daily';

alter table public.tv_featured_expressions enable row level security;

create policy tv_featured_anon_read
  on public.tv_featured_expressions for select
  to anon, authenticated
  using (active = true);

-- ── 3. Vista de reporting: expresiones más evaluadas ───────────────────────
create or replace view public.tv_popular_expressions
  with (security_invoker = true) as
  select
    expression,
    count(*)                          as times_calculated,
    count(distinct device_id)         as distinct_devices,
    max(created_at)                   as last_seen
  from public.tv_events
  where event_name = 'expression_calculated'
    and expression is not null
  group by expression
  order by times_calculated desc;

comment on view public.tv_popular_expressions is 'Reporting: expresiones más evaluadas (derivado de tv_events). Solo service_role.';;
