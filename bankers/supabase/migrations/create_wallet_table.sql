-- Wallet table: user earnings, redeemed amount, and balance
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor → New query)
--
-- If you use Supabase Auth: keep user_id and add:
--   REFERENCES auth.users(id) ON DELETE CASCADE
-- If user_id comes from your own API/users table: keep as TEXT (no FK).

CREATE TABLE IF NOT EXISTS wallet (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  earning DECIMAL(15, 2) NOT NULL DEFAULT 0 CHECK (earning >= 0),
  redeem DECIMAL(15, 2) NOT NULL DEFAULT 0 CHECK (redeem >= 0),
  balance DECIMAL(15, 2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
  currency TEXT NOT NULL DEFAULT 'INR',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Index for fast lookup by user_id
CREATE INDEX IF NOT EXISTS idx_wallet_user_id ON wallet(user_id);

-- Optional: trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_wallet_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS wallet_updated_at ON wallet;
CREATE TRIGGER wallet_updated_at
  BEFORE UPDATE ON wallet
  FOR EACH ROW
  EXECUTE PROCEDURE update_wallet_updated_at();

-- RLS: users can only access their own wallet row.
-- Requires Supabase Auth; user_id in wallet must match auth.uid()::text.
-- If you use custom auth / user_id from your API, use service_role for wallet access or adjust USING to your JWT claim.
ALTER TABLE wallet ENABLE ROW LEVEL SECURITY;

-- SELECT: user can read only their own wallet
CREATE POLICY "wallet_select_own"
  ON wallet FOR SELECT
  USING (auth.uid()::text = user_id);

-- INSERT: user can create only their own wallet row (e.g. on first load)
CREATE POLICY "wallet_insert_own"
  ON wallet FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);

-- UPDATE: user can update only their own wallet (e.g. balance/earning from app)
CREATE POLICY "wallet_update_own"
  ON wallet FOR UPDATE
  USING (auth.uid()::text = user_id)
  WITH CHECK (auth.uid()::text = user_id);

-- DELETE: users cannot delete wallet rows (use service role if needed)
-- No policy = denied for all. Uncomment below to allow user to delete own row:
-- CREATE POLICY "wallet_delete_own" ON wallet FOR DELETE USING (auth.uid()::text = user_id);

COMMENT ON TABLE wallet IS 'User wallet: earning, redeem, balance in INR';

-- When a new user is created (auth.users), auto-insert wallet row with 0 amount, INR
CREATE OR REPLACE FUNCTION public.handle_new_user_wallet()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.wallet (user_id, earning, redeem, balance, currency)
  VALUES (NEW.id::text, 0, 0, 0, 'INR')
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created_wallet ON auth.users;
CREATE TRIGGER on_auth_user_created_wallet
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE PROCEDURE public.handle_new_user_wallet();
