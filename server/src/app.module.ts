import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { SupabaseModule } from './config/supabase.module';
import { UsersModule } from './users/users.module';
import { OtpModule } from './otp/otp.module';
import { LeadsModule } from './leads/leads.module';
import { BannersModule } from './banners/banners.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: '.env' }),
    SupabaseModule,
    UsersModule,
    OtpModule,
    LeadsModule,
    BannersModule,
  ],
})
export class AppModule {}
