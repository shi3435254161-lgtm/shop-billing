-- ========================================
-- 商品记账系统 - Supabase 建表脚本
-- 在 Supabase 控制台的 SQL Editor 里执行
-- ========================================

-- 1. 商品表
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  price NUMERIC NOT NULL,
  category TEXT,
  image TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. 客户表
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. 客户账目表
CREATE TABLE IF NOT EXISTS ledger_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('sale', 'repair', 'payment')),
  description TEXT,
  amount NUMERIC NOT NULL,
  is_paid BOOLEAN DEFAULT false,
  recorded_by TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. 订单表
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  items JSONB NOT NULL,
  total NUMERIC NOT NULL,
  customer_id UUID REFERENCES customers(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. 关闭 RLS（统一账号模式，不走行级权限）
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE ledger_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 允许已认证用户完全访问所有表
CREATE POLICY "Allow all for authenticated" ON products FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated" ON customers FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated" ON ledger_entries FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for authenticated" ON orders FOR ALL USING (true) WITH CHECK (true);
