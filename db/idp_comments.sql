-- Bình luận cuối trang IDP ("Hãy để lại bình luận!").
-- Chạy một lần trong Supabase → SQL Editor. Chạy lại cũng không sao (không xoá dữ liệu).
--
-- Trang gọi thẳng REST API của Supabase bằng publishable key (khoá công khai), nên quyền nằm ở đây:
--   · ai mở trang cũng ĐỌC và GỬI được bình luận;
--   · chỉ được ghi 2 cột tên + nội dung (không tự đặt id / giờ gửi);
--   · không ai SỬA hay XOÁ được qua API. Muốn xoá thì vào Table Editor.

create table if not exists public.idp_comments (
  id          uuid primary key default gen_random_uuid(),
  author_name text not null check (char_length(btrim(author_name)) between 1 and 60),
  body        text not null check (char_length(btrim(body)) between 1 and 1000),
  created_at  timestamptz not null default now()
);

create index if not exists idp_comments_created_at_idx on public.idp_comments (created_at desc);

alter table public.idp_comments enable row level security;

drop policy if exists "idp_comments_read" on public.idp_comments;
create policy "idp_comments_read" on public.idp_comments
  for select to anon, authenticated
  using (true);

drop policy if exists "idp_comments_insert" on public.idp_comments;
create policy "idp_comments_insert" on public.idp_comments
  for insert to anon, authenticated
  with check (true); -- độ dài tên / nội dung đã chặn bằng CHECK ở bảng

revoke all on table public.idp_comments from anon, authenticated;
grant select on table public.idp_comments to anon, authenticated;
grant insert (author_name, body) on table public.idp_comments to anon, authenticated;
