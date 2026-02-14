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
    const { data, error } = await this.banners
      .select()
      .eq('is_active', true)
      .eq('category', category)
      .order('display_order', { ascending: true })
      .order('created_at', { ascending: false });

    if (error) {
      if (process.env.NODE_ENV !== 'production') {
        console.error('BannersService.getByCategory', error);
      }
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
      if (process.env.NODE_ENV !== 'production') {
        console.error('BannersService.getAll', error);
      }
      return [];
    }

    return this.mapToResponseDto(data || []);
  }

  private mapToResponseDto(data: Record<string, unknown>[]): BannerResponseDto[] {
    return data.map((item) => ({
      id: item.id as string,
      imageUrl: item.image_url as string,
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
