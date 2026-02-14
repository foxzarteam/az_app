import { Body, Controller, Get, Post, Res, HttpCode, HttpStatus } from '@nestjs/common';
import { Response } from 'express';
import { ConfigService } from '@nestjs/config';
import { OtpService } from './otp.service';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';

@Controller('otp')
export class OtpController {
  constructor(
    private readonly otpService: OtpService,
    private readonly config: ConfigService,
  ) {}

  @Post('send')
  @HttpCode(HttpStatus.OK)
  async send(@Body() dto: SendOtpDto) {
    return this.otpService.send(dto);
  }

  @Post('verify')
  @HttpCode(HttpStatus.OK)
  async verify(@Body() dto: VerifyOtpDto) {
    return this.otpService.verify(dto);
  }

  @Get('dev')
  dev(@Res() res: Response) {
    if (this.config.get<string>('NODE_ENV') === 'production') {
      return res.status(404).json({ error: 'Not found' });
    }
    const entries = this.otpService.getDevOtps();
    const rows = entries
      .map((e) => `<tr><td>${this.escapeHtml(e.mobile)}</td><td><strong>${e.otp}</strong></td><td>${this.escapeHtml(e.at)}</td></tr>`)
      .join('');
    const html = `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>OTP Dev</title>
<style>body{font-family:system-ui;max-width:600px;margin:2rem auto;padding:1rem}table{width:100%;border-collapse:collapse}th,td{padding:0.5rem;text-align:left;border-bottom:1px solid #ddd}th{background:#333;color:#fff}</style>
</head>
<body>
<h1>OTP Dev Logs</h1>
<table>
<thead><tr><th>Mobile</th><th>OTP</th><th>Time</th></tr></thead>
<tbody>${rows || '<tr><td colspan="3">No OTPs yet. Send one via POST /api/otp/send</td></tr>'}</tbody>
</table>
</body>
</html>`;
    res.type('text/html').send(html);
  }

  private escapeHtml(text: string): string {
    const map: Record<string, string> = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#039;',
    };
    return text.replace(/[&<>"']/g, (m) => map[m]);
  }
}
