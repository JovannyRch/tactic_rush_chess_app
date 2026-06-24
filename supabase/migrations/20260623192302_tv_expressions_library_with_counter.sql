-- ============================================================
-- Librería de expresiones con contador de popularidad.
-- Registro anónimo de expresiones de usuarios + lectura pública paginada.
-- ============================================================
create extension if not exists http with schema extensions;

create table if not exists public.tv_expressions (
  id          bigint generated always as identity primary key,
  expression  text        not null,
  -- clave normalizada (sin espacios) para unificar el contador entre variantes
  expr_key    text        generated always as (regexp_replace(expression, '\s+', '', 'g')) stored,
  type        text        not null check (type in ('TAUTOLOGY','CONTRADICTION','CONTINGENCY')),
  count       integer     not null default 1,
  video_link  text,
  origin      text        not null default 'user',
  first_seen  timestamptz not null default now(),
  last_seen   timestamptz not null default now()
);

comment on table public.tv_expressions is 'Librería de expresiones de Tablas de Verdad con contador de popularidad. Lectura pública; escritura solo vía RPC tv_register_expression.';

create unique index if not exists tv_expressions_expr_key_uidx on public.tv_expressions (expr_key);
create index if not exists tv_expressions_count_idx       on public.tv_expressions (count desc);
create index if not exists tv_expressions_type_count_idx  on public.tv_expressions (type, count desc);
create index if not exists tv_expressions_video_idx       on public.tv_expressions (count desc) where video_link is not null;

alter table public.tv_expressions enable row level security;

-- Lectura pública (la librería ya es pública vía el JSON estático).
create policy tv_expressions_anon_read
  on public.tv_expressions for select
  to anon, authenticated
  using (true);

-- ── RPC: registra/incrementa una expresión (único camino de escritura) ──────
create or replace function public.tv_register_expression(p_expression text, p_type text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_expression is null
     or length(btrim(p_expression)) = 0
     or length(p_expression) > 200 then
    return;
  end if;
  if p_type not in ('TAUTOLOGY','CONTRADICTION','CONTINGENCY') then
    return;
  end if;

  insert into public.tv_expressions (expression, type, count, origin)
  values (btrim(p_expression), p_type, 1, 'user')
  on conflict (expr_key) do update
    set count     = public.tv_expressions.count + 1,
        last_seen = now(),
        type      = excluded.type;
end;
$$;

revoke all on function public.tv_register_expression(text, text) from public;
grant execute on function public.tv_register_expression(text, text) to anon, authenticated;

-- ── Siembra: importa la librería actual (JSON estático) con sus contadores ──
insert into public.tv_expressions (expression, type, count, video_link, origin)
select expression, type, cnt, video_link, 'seed'
from (
  select distinct on (regexp_replace(e->>'expression', '\s+', '', 'g'))
    e->>'expression'                              as expression,
    e->>'type'                                    as type,
    coalesce(nullif(e->>'counter','')::int, 1)    as cnt,
    nullif(e->>'video_link','')                   as video_link
  from (
    select content
    from extensions.http_get('https://static-json-backend.vercel.app/projects/truth-tables/expressions')
  ) r,
  lateral jsonb_array_elements((r.content::jsonb)->'data') e
  order by regexp_replace(e->>'expression', '\s+', '', 'g'),
           coalesce(nullif(e->>'counter','')::int, 1) desc
) s
where type in ('TAUTOLOGY','CONTRADICTION','CONTINGENCY')
on conflict (expr_key) do nothing;;
