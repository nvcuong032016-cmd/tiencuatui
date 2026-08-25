create extension if not exists pgcrypto;

create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  number text not null check (char_length(number) = 4),
  bank text not null,
  type text not null check (type in ('visa', 'mastercard', 'jcb')),
  expiry text not null,
  grace_days integer not null check (grace_days in (45, 55)),
  statement_day integer not null check (statement_day between 1 and 31),
  payment_day integer not null check (payment_day between 1 and 31),
  credit_limit bigint not null check (credit_limit > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.loans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null,
  bank text not null,
  amount bigint not null check (amount > 0),
  installments integer not null check (installments in (6, 12, 24)),
  monthly bigint not null check (monthly > 0),
  note text not null default '',
  paid text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.lendings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null,
  amount bigint not null check (amount > 0),
  start_date timestamptz not null,
  type text not null check (type in ('savings', 'lending')),
  target text not null check (target in ('individual', 'organization')),
  paid bigint not null default 0 check (paid >= 0),
  note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.cards enable row level security;
alter table public.loans enable row level security;
alter table public.lendings enable row level security;

grant usage on schema public to authenticated;
grant select, insert, update, delete on public.cards to authenticated;
grant select, insert, update, delete on public.loans to authenticated;
grant select, insert, update, delete on public.lendings to authenticated;

drop policy if exists "cards_select_own" on public.cards;
drop policy if exists "cards_insert_own" on public.cards;
drop policy if exists "cards_update_own" on public.cards;
drop policy if exists "cards_delete_own" on public.cards;
drop policy if exists "loans_select_own" on public.loans;
drop policy if exists "loans_insert_own" on public.loans;
drop policy if exists "loans_update_own" on public.loans;
drop policy if exists "loans_delete_own" on public.loans;
drop policy if exists "lendings_select_own" on public.lendings;
drop policy if exists "lendings_insert_own" on public.lendings;
drop policy if exists "lendings_update_own" on public.lendings;
drop policy if exists "lendings_delete_own" on public.lendings;

create policy "cards_select_own" on public.cards for select to authenticated using ((select auth.uid()) = user_id);
create policy "cards_insert_own" on public.cards for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "cards_update_own" on public.cards for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "cards_delete_own" on public.cards for delete to authenticated using ((select auth.uid()) = user_id);

create policy "loans_select_own" on public.loans for select to authenticated using ((select auth.uid()) = user_id);
create policy "loans_insert_own" on public.loans for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "loans_update_own" on public.loans for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "loans_delete_own" on public.loans for delete to authenticated using ((select auth.uid()) = user_id);

create policy "lendings_select_own" on public.lendings for select to authenticated using ((select auth.uid()) = user_id);
create policy "lendings_insert_own" on public.lendings for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "lendings_update_own" on public.lendings for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "lendings_delete_own" on public.lendings for delete to authenticated using ((select auth.uid()) = user_id);
