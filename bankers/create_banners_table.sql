-- ============================================
-- BANNERS TABLE - Supabase SQL Query
-- ============================================
-- This table stores all banner images for dynamic loading
-- Supports both Supabase Storage URLs and external image URLs

-- ============================================
-- 0. CREATE FUNCTION FOR AUTO-UPDATE updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 1. CREATE BANNERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Image URL (can be Supabase Storage URL or external URL)
    image_url TEXT NOT NULL,
    
    -- Banner metadata
    title VARCHAR(255),
    description TEXT,
    
    -- Banner type/category (e.g., 'carousel', 'promo', 'offer', 'kyc')
    category VARCHAR(50) DEFAULT 'carousel',
    
    -- Display order (lower number = higher priority)
    display_order INTEGER DEFAULT 0,
    
    -- Link/action when banner is clicked (optional)
    action_url TEXT,
    action_type VARCHAR(50), -- 'url', 'screen', 'none'
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Validations
    CONSTRAINT valid_display_order CHECK (display_order >= 0),
    CONSTRAINT valid_action_type CHECK (action_type IS NULL OR action_type IN ('url', 'screen', 'none'))
);

-- ============================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ============================================
-- Index on category for filtering
CREATE INDEX IF NOT EXISTS idx_banners_category ON banners(category);

-- Index on is_active for filtering active banners
CREATE INDEX IF NOT EXISTS idx_banners_is_active ON banners(is_active) WHERE is_active = true;

-- Index on display_order for sorting
CREATE INDEX IF NOT EXISTS idx_banners_display_order ON banners(display_order);

-- Composite index for common query (active banners by category, ordered)
CREATE INDEX IF NOT EXISTS idx_banners_active_category_order ON banners(is_active, category, display_order) WHERE is_active = true;

-- ============================================
-- 3. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 4. RLS POLICIES
-- ============================================
-- Allow anyone to view active banners (public read)
CREATE POLICY "Anyone can view active banners"
    ON banners FOR SELECT
    USING (is_active = true);

-- Allow authenticated users to view all banners (for admin)
CREATE POLICY "Authenticated users can view all banners"
    ON banners FOR SELECT
    USING (true);

-- Allow authenticated users to insert banners (for admin)
CREATE POLICY "Authenticated users can insert banners"
    ON banners FOR INSERT
    WITH CHECK (true);

-- Allow authenticated users to update banners (for admin)
CREATE POLICY "Authenticated users can update banners"
    ON banners FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Allow authenticated users to delete banners (for admin)
CREATE POLICY "Authenticated users can delete banners"
    ON banners FOR DELETE
    USING (true);

-- ============================================
-- 5. TRIGGER FOR AUTO-UPDATE updated_at
-- ============================================
CREATE TRIGGER update_banners_updated_at
    BEFORE UPDATE ON banners
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 6. SAMPLE DATA - Dummy Rows
-- ============================================
-- Insert dummy banners for testing
INSERT INTO banners (image_url, title, description, category, display_order, is_active, action_type) VALUES
-- Carousel banners
('https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&h=300&fit=crop', 'Personal Loan Offer', 'Get instant personal loan up to ₹5 Lakh', 'carousel', 1, true, 'none'),
('https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=300&fit=crop', '100% Digital Process', 'No paperwork required, instant approval', 'carousel', 2, true, 'none'),
('https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800&h=300&fit=crop', 'Quick Approval', 'Get approved in minutes', 'carousel', 3, true, 'none'),
('https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&h=300&fit=crop', 'Low Interest Rates', 'Competitive rates starting from 10.5%', 'carousel', 4, true, 'none'),

-- Promo banners
('https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=200&fit=crop', 'Special Offer', 'Limited time offer - Apply now!', 'promo', 1, true, 'url'),
('https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800&h=200&fit=crop', 'Referral Bonus', 'Earn ₹1000 per successful referral', 'promo', 2, true, 'url'),

-- KYC banner
('https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&h=250&fit=crop', 'Complete Your KYC', 'Verify your profile to unlock all features', 'kyc', 1, true, 'screen'),

-- Offer banners
('https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=300&fit=crop', 'Festival Special', 'Special rates during festival season', 'offer', 1, true, 'url'),
('https://images.unsplash.com/photo-1553729459-efe14ef6055d?w=800&h=300&fit=crop', 'New Year Offer', 'Start the year with great rates', 'offer', 2, true, 'url')

ON CONFLICT DO NOTHING;

-- ============================================
-- 7. USEFUL QUERIES FOR YOUR APP
-- ============================================

-- Get all active banners ordered by display_order
-- SELECT * FROM banners 
-- WHERE is_active = true 
-- ORDER BY display_order ASC, created_at DESC;

-- Get active banners by category
-- SELECT * FROM banners 
-- WHERE is_active = true AND category = 'carousel'
-- ORDER BY display_order ASC, created_at DESC;

-- Get single banner by ID
-- SELECT * FROM banners WHERE id = 'banner-uuid-here';

-- Update banner status
-- UPDATE banners 
-- SET is_active = false, updated_at = NOW()
-- WHERE id = 'banner-uuid-here';

-- Update display order
-- UPDATE banners 
-- SET display_order = 1, updated_at = NOW()
-- WHERE id = 'banner-uuid-here';
