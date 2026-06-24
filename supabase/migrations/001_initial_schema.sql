-- ============================================================
-- Mapingo Database Schema
-- Migration: 001_initial_schema
-- ============================================================

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Updated at trigger function
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;
-- Profile creation trigger function
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'Explorer')
  );
  return new;
end;
$$ language plpgsql security definer;
-- ============================================================
-- TABLES
-- ============================================================

-- 1. Profiles
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text,
  avatar_url text,
  total_xp integer not null default 0,
  current_streak integer not null default 0,
  longest_streak integer not null default 0,
  last_activity_date date,
  onboarding_completed boolean not null default false,
  daily_goal_minutes integer not null default 5,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
-- 2. Regions
create table public.regions (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  order_index integer not null default 0,
  created_at timestamptz not null default now()
);
-- 3. States
create table public.states (
  id uuid primary key default gen_random_uuid(),
  region_id uuid references public.regions(id) on delete set null,
  name text not null unique,
  capital text not null,
  abbreviation text not null unique,
  description text,
  fun_fact text,
  map_key text not null unique,
  silhouette_asset text,
  color_hex text,
  order_index integer not null default 0,
  created_at timestamptz not null default now()
);
-- 4. Units
create table public.units (
  id uuid primary key default gen_random_uuid(),
  region_id uuid references public.regions(id) on delete set null,
  title text not null,
  description text,
  order_index integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
-- 5. Lessons
create table public.lessons (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references public.units(id) on delete cascade,
  title text not null,
  description text,
  lesson_type text not null default 'standard',
  order_index integer not null default 0,
  xp_reward integer not null default 10,
  required_lesson_id uuid references public.lessons(id) on delete set null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
-- 6. Exercises
create table public.exercises (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  exercise_type text not null,
  question text not null,
  correct_answer text not null,
  options jsonb,
  metadata jsonb,
  explanation text,
  difficulty integer not null default 1,
  order_index integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
-- 7. User Lesson Progress
create table public.user_lesson_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  completed boolean not null default false,
  score integer not null default 0,
  accuracy numeric(5,2) not null default 0,
  correct_answers integer not null default 0,
  wrong_answers integer not null default 0,
  xp_earned integer not null default 0,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, lesson_id)
);
-- 8. User Exercise Attempts
create table public.user_exercise_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id) on delete cascade,
  selected_answer text,
  is_correct boolean not null,
  time_spent_seconds integer,
  created_at timestamptz not null default now()
);
-- 9. User Mistakes
create table public.user_mistakes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  exercise_id uuid not null references public.exercises(id) on delete cascade,
  mistake_count integer not null default 1,
  last_wrong_at timestamptz not null default now(),
  last_reviewed_at timestamptz,
  resolved boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, exercise_id)
);
-- 10. User Daily Activity
create table public.user_daily_activity (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  activity_date date not null,
  xp_earned integer not null default 0,
  lessons_completed integer not null default 0,
  exercises_completed integer not null default 0,
  minutes_practiced integer not null default 0,
  created_at timestamptz not null default now(),
  unique(user_id, activity_date)
);
-- 11. Achievements
create table public.achievements (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text not null,
  description text not null,
  icon text,
  xp_reward integer not null default 0,
  condition_type text not null,
  condition_value integer not null default 1,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
-- 12. User Achievements
create table public.user_achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_id uuid not null references public.achievements(id) on delete cascade,
  unlocked_at timestamptz not null default now(),
  unique(user_id, achievement_id)
);
-- ============================================================
-- CONSTRAINTS
-- ============================================================

alter table public.profiles
  add constraint profiles_total_xp_check check (total_xp >= 0),
  add constraint profiles_current_streak_check check (current_streak >= 0),
  add constraint profiles_longest_streak_check check (longest_streak >= 0),
  add constraint profiles_daily_goal_minutes_check check (daily_goal_minutes > 0);
alter table public.lessons
  add constraint lessons_xp_reward_check check (xp_reward > 0);
alter table public.exercises
  add constraint exercises_difficulty_check check (difficulty between 1 and 5);
alter table public.user_lesson_progress
  add constraint user_lesson_progress_accuracy_check check (accuracy >= 0 and accuracy <= 100),
  add constraint user_lesson_progress_score_check check (score >= 0),
  add constraint user_lesson_progress_xp_earned_check check (xp_earned >= 0);
-- ============================================================
-- INDEXES
-- ============================================================

create index idx_states_region_id on public.states(region_id);
create index idx_units_region_id on public.units(region_id);
create index idx_lessons_unit_id on public.lessons(unit_id);
create index idx_exercises_lesson_id on public.exercises(lesson_id);
create index idx_user_lesson_progress_user_id on public.user_lesson_progress(user_id);
create index idx_user_lesson_progress_lesson_id on public.user_lesson_progress(lesson_id);
create index idx_user_exercise_attempts_user_id on public.user_exercise_attempts(user_id);
create index idx_user_exercise_attempts_exercise_id on public.user_exercise_attempts(exercise_id);
create index idx_user_mistakes_user_id on public.user_mistakes(user_id);
create index idx_user_mistakes_exercise_id on public.user_mistakes(exercise_id);
create index idx_user_daily_activity_user_id on public.user_daily_activity(user_id);
create index idx_user_daily_activity_date on public.user_daily_activity(activity_date);
create index idx_user_achievements_user_id on public.user_achievements(user_id);
-- ============================================================
-- TRIGGERS
-- ============================================================

-- Updated at triggers
create trigger set_profiles_updated_at
  before update on public.profiles
  for each row
  execute function public.set_updated_at();
create trigger set_user_lesson_progress_updated_at
  before update on public.user_lesson_progress
  for each row
  execute function public.set_updated_at();
create trigger set_user_mistakes_updated_at
  before update on public.user_mistakes
  for each row
  execute function public.set_updated_at();
-- Profile creation trigger
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();
-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.regions enable row level security;
alter table public.states enable row level security;
alter table public.units enable row level security;
alter table public.lessons enable row level security;
alter table public.exercises enable row level security;
alter table public.user_lesson_progress enable row level security;
alter table public.user_exercise_attempts enable row level security;
alter table public.user_mistakes enable row level security;
alter table public.user_daily_activity enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
-- ============================================================
-- RLS POLICIES - PUBLIC READ TABLES
-- ============================================================

-- Regions
create policy "Allow public read access"
  on public.regions
  for select
  using (true);
-- States
create policy "Allow public read access"
  on public.states
  for select
  using (true);
-- Units
create policy "Allow public read access"
  on public.units
  for select
  using (true);
-- Lessons
create policy "Allow public read access"
  on public.lessons
  for select
  using (true);
-- Exercises
create policy "Allow public read access"
  on public.exercises
  for select
  using (true);
-- Achievements
create policy "Allow public read access"
  on public.achievements
  for select
  using (true);
-- ============================================================
-- RLS POLICIES - PROFILES
-- ============================================================

create policy "Users can read their own profile"
  on public.profiles
  for select
  using (auth.uid() = id);
create policy "Users can update their own profile"
  on public.profiles
  for update
  using (auth.uid() = id);
create policy "Users can insert their own profile"
  on public.profiles
  for insert
  with check (auth.uid() = id);
-- ============================================================
-- RLS POLICIES - USER LESSON PROGRESS
-- ============================================================

create policy "Users can read their own lesson progress"
  on public.user_lesson_progress
  for select
  using (auth.uid() = user_id);
create policy "Users can insert their own lesson progress"
  on public.user_lesson_progress
  for insert
  with check (auth.uid() = user_id);
create policy "Users can update their own lesson progress"
  on public.user_lesson_progress
  for update
  using (auth.uid() = user_id);
-- ============================================================
-- RLS POLICIES - USER EXERCISE ATTEMPTS
-- ============================================================

create policy "Users can read their own exercise attempts"
  on public.user_exercise_attempts
  for select
  using (auth.uid() = user_id);
create policy "Users can insert their own exercise attempts"
  on public.user_exercise_attempts
  for insert
  with check (auth.uid() = user_id);
-- ============================================================
-- RLS POLICIES - USER MISTAKES
-- ============================================================

create policy "Users can read their own mistakes"
  on public.user_mistakes
  for select
  using (auth.uid() = user_id);
create policy "Users can insert their own mistakes"
  on public.user_mistakes
  for insert
  with check (auth.uid() = user_id);
create policy "Users can update their own mistakes"
  on public.user_mistakes
  for update
  using (auth.uid() = user_id);
-- ============================================================
-- RLS POLICIES - USER DAILY ACTIVITY
-- ============================================================

create policy "Users can read their own daily activity"
  on public.user_daily_activity
  for select
  using (auth.uid() = user_id);
create policy "Users can insert their own daily activity"
  on public.user_daily_activity
  for insert
  with check (auth.uid() = user_id);
create policy "Users can update their own daily activity"
  on public.user_daily_activity
  for update
  using (auth.uid() = user_id);
-- ============================================================
-- RLS POLICIES - USER ACHIEVEMENTS
-- ============================================================

create policy "Users can read their own achievements"
  on public.user_achievements
  for select
  using (auth.uid() = user_id);
create policy "Users can insert their own achievements"
  on public.user_achievements
  for insert
  with check (auth.uid() = user_id);
