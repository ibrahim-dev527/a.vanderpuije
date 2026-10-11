-- =========================================================
-- A.Vanderpuije Clothing — Supabase schema
-- Run this once in your Supabase project's SQL Editor
-- (Dashboard → SQL Editor → New query → paste → Run)
-- =========================================================

-- 1. PRODUCTS ------------------------------------------------
-- "name" is the full descriptive line shown on the shop card, e.g.
-- "Corset style top with full flare skirt (2 piece set)" — write it
-- exactly the way you want the customer to read it.
-- "category" is ONE of: two-piece, boubous-maxis, blacks, prints,
-- occasions, pants-set, kaftans — matching the menu on the site.
-- "size" is free text, e.g. "12-16" or "One Size" — not a list of
-- sizes to choose from, since each listing is one fixed size run.
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  code text,                                -- optional, for your own tracking only
  name text not null,
  description text,
  price numeric(10,2) not null,
  category text not null default 'occasions',
  size text not null default 'One Size',
  featured boolean not null default false,
  stock integer not null default 0,
  image_url text,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

-- 2. ORDERS ----------------------------------------------------
create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  reference text unique not null,          -- Paystack transaction reference
  customer_name text not null,
  phone text not null,
  email text not null,
  address text not null,
  notes text,
  total numeric(10,2) not null,
  status text not null default 'awaiting_confirmation',  -- awaiting_confirmation | paid | fulfilled | cancelled
  created_at timestamptz not null default now()
);

-- 3. ORDER ITEMS -------------------------------------------------
create table if not exists order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid references orders(id) on delete cascade,
  product_id uuid references products(id),
  product_name text not null,   -- snapshot, in case the product changes later
  size text not null,
  qty integer not null,
  price numeric(10,2) not null  -- snapshot of the price at time of sale
);

-- =========================================================
-- ROW LEVEL SECURITY
-- Public (customers) can only READ active products.
-- Only logged-in admin users can write to any table.
-- =========================================================
alter table products enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;

create policy "Public can view active products"
  on products for select
  using (active = true);

create policy "Authenticated users can manage products"
  on products for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "Authenticated users can manage orders"
  on orders for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "Authenticated users can manage order items"
  on order_items for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- Orders need to be INSERTable by the public checkout flow too
-- (a customer is not logged in when they pay). This policy allows
-- anyone to create an order, but never to read, update or delete one.
create policy "Anyone can create an order"
  on orders for insert
  with check (true);

create policy "Anyone can create order items"
  on order_items for insert
  with check (true);

-- =========================================================
-- STORAGE
-- Create a public bucket called "product-images" from
-- Dashboard → Storage → New bucket → name it product-images,
-- toggle "Public bucket" ON. No SQL needed for that part.
-- =========================================================

-- =========================================================
-- SEED DATA (optional) — loads the current placeholder catalog
-- so your admin dashboard isn't empty on first login. Replace
-- image_url values with your own Supabase Storage URLs once you
-- upload real photos.
-- =========================================================
insert into products (code, name, description, price, category, size, featured, stock, image_url, active) values
('AV 1001','Off shoulder puff sleeve gown with a fitted waist and flowing skirt','A bold red, blue and gold print gown with puffed sleeves.',950,'occasions','10-16',true,8,'assets/images/fashion-01.jpg',true),
('AV 1002','Button front sleeveless midi dress with a structured collar','A rust and gold print sleeveless midi dress.',650,'prints','8-14',false,6,'assets/images/fashion-02.jpg',true),
('AV 1003','Wrap style maxi dress with ruffle trim and a tie waist','A teal and purple floral wrap dress with ruffle detailing.',700,'occasions','10-16',false,5,'assets/images/fashion-03.jpg',true),
('AV 1004','Tie shoulder gown with an open back and flowing skirt','A blue and red print gown with tie shoulder straps.',780,'occasions','10-14',false,4,'assets/images/fashion-04.jpg',true),
('AV 1005','High waisted patchwork print maxi skirt, pair with any top','A panelled skirt in mixed African prints.',520,'prints','10-18',true,7,'assets/images/fashion-05.jpg',true),
('AV 1006','Halter top and wide leg trouser two piece set','A mustard tie dye halter top and trouser set.',600,'two-piece','10-16',true,6,'assets/images/fashion-06.jpg',true),
('AV 1007','Sweetheart neckline fit and flare dress with tie straps','A red and black abstract print dress.',720,'occasions','8-14',false,5,'assets/images/fashion-07.jpg',true),
('AV 1008','Batik print kaftan top and trouser two piece set','A magenta batik print kaftan top and trouser two piece.',680,'two-piece','12-18',false,5,'assets/images/fashion-08.jpg',true),
('AV 1009','Peplum print overlay, worn over a fitted black dress','A pink and orange print peplum top over a black dress.',560,'blacks','10-16',true,6,'assets/images/fashion-09.jpg',true),
('AV 1010','Deep V cowl neck jumpsuit in a bold tie dye print','A mustard tie dye jumpsuit with a deep V neckline.',640,'prints','10-14',false,4,'assets/images/fashion-10.jpg',true),
('AV 1011','Tie shoulder gown in a bold painterly print with a full skirt','A full skirted gown in a bold painterly print.',890,'occasions','10-16',true,4,'assets/images/fashion-11.jpg',true),
('AV 1012','Corset style top with full flare skirt (2 piece set)','A birdcage print corset style top with a full flare skirt.',680,'two-piece','12-16',true,5,'assets/images/hero-corset-dress.jpg',true);

-- =========================================================
-- CHAT ASSISTANT FAQ (answers you add from admin.html → FAQ tab)
-- keywords = comma separated words customers might type
-- show_button = show this question as a quick button in the chat
-- =========================================================
create table if not exists faqs (
  id uuid primary key default gen_random_uuid(),
  question text not null,
  keywords text,
  answer text not null,
  show_button boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table faqs enable row level security;

create policy "Public can read active faqs"
  on faqs for select
  using (active = true);

create policy "Authenticated users can manage faqs"
  on faqs for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- Let visitors upload nothing, but let signed in admins upload product photos:
-- (Storage policies) run these after creating the public "product-images" bucket
create policy "Admins can upload product images"
  on storage.objects for insert
  with check (bucket_id = 'product-images' and auth.role() = 'authenticated');
create policy "Admins can update product images"
  on storage.objects for update
  using (bucket_id = 'product-images' and auth.role() = 'authenticated');
create policy "Admins can delete product images"
  on storage.objects for delete
  using (bucket_id = 'product-images' and auth.role() = 'authenticated');
create policy "Anyone can view product images"
  on storage.objects for select
  using (bucket_id = 'product-images');
