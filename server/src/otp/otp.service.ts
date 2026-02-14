import { Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_CLIENT } from '../config/supabase.config';
import {
  TABLE_OTP_SESSIONS,
  OTP_LENGTH,
  OTP_EXPIRY_MINUTES,
  OTP_MAX_ATTEMPTS,
  FAST2SMS_DEFAULT_BASE_URL,
  FAST2SMS_ROUTE_OTP,
  getCurrentIsoTime,
  MSG_OTP_SESSION_FAILED,
  MSG_OTP_SEND_FAILED,
  MSG_OTP_SENT,
  MSG_OTP_VERIFY_FAILED,
  MSG_OTP_INVALID_EXPIRED,
  MSG_OTP_MAX_ATTEMPTS,
  MSG_OTP_VERIFIED,
} from '../common/constants';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';

export type OtpResult = { success: boolean; message: string };

interface DevOtpEntry {
  mobile: string;
  otp: string;
  at: string;
}

@Injectable()
export class OtpService {
  private devOtps: DevOtpEntry[] = [];
  private static readonly MAX_DEV_OTPS = 20;

  constructor(
    @Inject(SUPABASE_CLIENT) private readonly supabase: SupabaseClient,
    private readonly config: ConfigService,
  ) {}

  private get otpSessions() {
    return this.supabase.from(TABLE_OTP_SESSIONS);
  }

  private generateOtp(): string {
    let otp = '';
    for (let i = 0; i < OTP_LENGTH; i++) {
      otp += Math.floor(Math.random() * 10);
    }
    return otp;
  }

  private getExpiryTime(): string {
    const d = new Date();
    d.setMinutes(d.getMinutes() + OTP_EXPIRY_MINUTES);
    return d.toISOString();
  }

  private async createOtpSession(
    mobileNumber: string,
    otp: string,
    expiresAt: string,
  ): Promise<OtpResult | null> {
    const { error } = await this.otpSessions.insert({
      mobile_number: mobileNumber,
      otp_code: otp,
      expires_at: expiresAt,
      is_verified: false,
      attempts: 0,
      max_attempts: OTP_MAX_ATTEMPTS,
    });
    if (error) {
      if (process.env.NODE_ENV !== 'production') {
        console.error('OtpService.createOtpSession', error);
      }
      return { success: false, message: MSG_OTP_SESSION_FAILED };
    }
    return null;
  }

  private async sendSmsViaFast2Sms(
    mobileNumber: string,
    otp: string,
  ): Promise<OtpResult | null> {
    const apiKey = this.config.get<string>('FAST2SMS_API_KEY');
    const baseUrl = this.config.get<string>(
      'FAST2SMS_BASE_URL',
      FAST2SMS_DEFAULT_BASE_URL,
    );
    if (!apiKey || !baseUrl) return null;

    try {
      const res = await fetch(baseUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          authorization: apiKey,
        },
        body: JSON.stringify({
          route: FAST2SMS_ROUTE_OTP,
          variables_values: otp,
          numbers: mobileNumber,
        }),
      });
      const json = (await res.json()) as { return?: boolean; message?: string };
      if (!json.return) {
        if (process.env.NODE_ENV !== 'production') {
          console.warn('Fast2SMS send failed:', json.message);
        }
        return {
          success: false,
          message: json.message ?? MSG_OTP_SEND_FAILED,
        };
      }
      return null;
    } catch (e) {
      if (process.env.NODE_ENV !== 'production') {
        console.warn('Fast2SMS request error:', e);
      }
      return { success: false, message: MSG_OTP_SEND_FAILED };
    }
  }

  async send(dto: SendOtpDto): Promise<OtpResult> {
    const otp = this.generateOtp();
    const expiresAt = this.getExpiryTime();

    const sessionError = await this.createOtpSession(
      dto.mobileNumber,
      otp,
      expiresAt,
    );
    if (sessionError) return sessionError;

    const smsError = await this.sendSmsViaFast2Sms(dto.mobileNumber, otp);
    if (smsError) return smsError;

    const apiKey = this.config.get<string>('FAST2SMS_API_KEY');
    if (!apiKey) {
      this.devOtps.unshift({
        mobile: dto.mobileNumber,
        otp,
        at: new Date().toISOString(),
      });
      if (this.devOtps.length > OtpService.MAX_DEV_OTPS) {
        this.devOtps.pop();
      }
    }

    return { success: true, message: MSG_OTP_SENT };
  }

  getDevOtps(): DevOtpEntry[] {
    return [...this.devOtps];
  }

  async verify(dto: VerifyOtpDto): Promise<OtpResult> {
    const now = getCurrentIsoTime();
    const { data: rows, error } = await this.otpSessions
      .select('id, attempts, max_attempts')
      .eq('mobile_number', dto.mobileNumber)
      .eq('otp_code', dto.otp)
      .eq('is_verified', false)
      .gt('expires_at', now);

    if (error) {
      if (process.env.NODE_ENV !== 'production') {
        console.error('OtpService.verify select', error);
      }
      return { success: false, message: MSG_OTP_VERIFY_FAILED };
    }

    const session = Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
    if (!session) {
      return { success: false, message: MSG_OTP_INVALID_EXPIRED };
    }

    const attempts = (session.attempts as number) ?? 0;
    const maxAttempts = (session.max_attempts as number) ?? OTP_MAX_ATTEMPTS;
    if (attempts >= maxAttempts) {
      return { success: false, message: MSG_OTP_MAX_ATTEMPTS };
    }

    const { error: updateErr } = await this.otpSessions
      .update({
        is_verified: true,
        verified_at: getCurrentIsoTime(),
      })
      .eq('id', session.id);

    if (updateErr) {
      if (process.env.NODE_ENV !== 'production') {
        console.error('OtpService.verify update', updateErr);
      }
      return { success: false, message: MSG_OTP_VERIFY_FAILED };
    }

    return { success: true, message: MSG_OTP_VERIFIED };
  }
}
