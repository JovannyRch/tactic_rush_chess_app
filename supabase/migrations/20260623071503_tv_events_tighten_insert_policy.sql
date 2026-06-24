-- Endurece la política de inserción anónima: sigue permitiendo telemetría
-- sin login, pero valida la forma del payload (anti-abuso + silencia linter).
drop policy if exists tv_events_anon_insert on public.tv_events;

create policy tv_events_anon_insert
  on public.tv_events for insert
  to anon, authenticated
  with check (
    event_name is not null
    and char_length(event_name) <= 64
    and (expression  is null or char_length(expression)  <= 200)
    and (locale      is null or char_length(locale)      <= 10)
    and (app_version is null or char_length(app_version) <= 20)
    and (platform    is null or platform in ('android','ios','macos','other'))
  );;
