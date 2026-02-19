import { Inject, Injectable } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_CLIENT } from '../config/supabase.config';
import { TABLE_BANNERS } from '../common/constants';
import { BannerResponseDto } from './dto/banner-response.dto';

@Injectable()
export class BannersService {
  constructor(
    @Inject(SUPABASE_CLIENT) private readonly supabase: SupabaseClient,
  ) {}

  private get banners() {
    return this.supabase.from(TABLE_BANNERS);
  }

  async getAllActive(): Promise<BannerResponseDto[]> {
    const { data, error } = await this.banners
      .select()
      .eq('is_active', true)
      .order('display_order', { ascending: true })
      .order('created_at', { ascending: false });

    if (error) {
      if (process.env.NODE_ENV !== 'production') {
        console.error('BannersService.getAllActive', error);
      }
      return [];
    }

    return this.mapToResponseDto(data || []);
  }

  async getByCategory(category: string): Promise<BannerResponseDto[]> {
    // Normalize category to lowercase for case-insensitive matching
    const normalizedCategory = category.toLowerCase().trim();
    
    // First try exact match (most common case)
    let { data, error } = await this.banners
      .select()
      .eq('is_active', true)
      .eq('category', normalizedCategory)
      .order('display_order', { ascending: true })
      .order('created_at', { ascending: false });

    // If no results, try case-insensitive match by fetching all active and filtering
    if (!error && (!data || data.length === 0)) {
      const { data: allData, error: allError } = await this.banners
        .select()
        .eq('is_active', true)
        .order('display_order', { ascending: true })
        .order('created_at', { ascending: false });
      
      if (!allError && allData) {
        data = allData.filter((row) => 
          (row.category as string)?.toLowerCase() === normalizedCategory
        );
        error = null;
      }
    }

    if (error) {
      console.error('BannersService.getByCategory error', error.message);
      return [];
    }

    const rows = data || [];
    if (process.env.NODE_ENV !== 'production' || rows.length === 0) {
      console.log(`BannersService.getByCategory('${category}' -> '${normalizedCategory}'): rows=${rows.length}, first image_url=${rows[0] ? (rows[0] as Record<string, unknown>).image_url : 'n/a'}`);
    }

    return this.mapToResponseDto(rows);
  }

  async getAll(): Promise<BannerResponseDto[]> {
    const { data, error } = await this.banners
      .select()
      .order('display_order', { ascending: true })
      .order('created_at', { ascending: false });

    if (error) {
      if (process.env.NODE_ENV !== 'production') {
        console.error('BannersService.getAll', error);
      }
      return [];
    }

    return this.mapToResponseDto(data || []);
  }

  /** Pass through any non-empty http(s) URL from DB; only skip empty or clearly non-URL values */
  private getImageUrl(url: unknown): string {
    if (typeof url !== 'string' || !url.trim()) return '';
    const u = url.trim();
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    return '';
  }

  private mapToResponseDto(data: Record<string, unknown>[]): BannerResponseDto[] {
    return data.map((item) => ({
      id: item.id as string,
      imageUrl: this.getImageUrl(item.image_url),
      title: item.title as string | undefined,
      description: item.description as string | undefined,
      category: (item.category as string) || 'carousel',
      displayOrder: (item.display_order as number) || 0,
      actionUrl: item.action_url as string | undefined,
      actionType: item.action_type as string | undefined,
      isActive: (item.is_active as boolean) ?? true,
      createdAt: item.created_at as string,
      updatedAt: item.updated_at as string,
    }));
  }
}
