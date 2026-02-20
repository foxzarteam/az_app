import { Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_CLIENT } from '../config/supabase.config';
import { TABLE_BANNERS } from '../common/constants';
import { BannerResponseDto } from './dto/banner-response.dto';

@Injectable()
export class BannersService {
  constructor(
    @Inject(SUPABASE_CLIENT) private readonly supabase: SupabaseClient,
    private readonly config: ConfigService,
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
      return [];
    }

    return this.mapToResponseDto(data || []);
  }

  async getByCategory(category: string): Promise<BannerResponseDto[]> {
    const { data, error } = await this.banners
      .select()
      .eq('is_active', true)
      .eq('category', category)
      .order('display_order', { ascending: true })
      .order('created_at', { ascending: false });

    if (error) {
      return [];
    }

    return this.mapToResponseDto(data || []);
  }

  async getAll(): Promise<BannerResponseDto[]> {
    const { data, error } = await this.banners
      .select()
      .order('display_order', { ascending: true })
      .order('created_at', { ascending: false });

    if (error) {
      return [];
    }

    return this.mapToResponseDto(data || []);
  }

  private getImageUrl(url: unknown): string {
    if (typeof url !== 'string' || !url.trim()) return '';
    let u = url.trim();
    
    if (u.startsWith('http://') || u.startsWith('https://')) {
      return u;
    }
    
    const baseUrl = process.env.BASE_URL || this.config.get<string>('BASE_URL');
    
    if (!baseUrl) {
      const port = this.config.get<number>('PORT', 3000);
      const fallbackUrl = `http://localhost:${port}`;
      if (u.startsWith('/')) {
        u = u.substring(1);
      }
      if (u.startsWith('images/')) {
        u = u.substring(7);
      }
      return `${fallbackUrl}/images/${u}`;
    }
    
    if (u.startsWith('/')) {
      u = u.substring(1);
    }
    
    if (u.startsWith('images/')) {
      u = u.substring(7);
    }
    
    const cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.slice(0, -1) : baseUrl;
    
    return `${cleanBaseUrl}/images/${u}`;
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
