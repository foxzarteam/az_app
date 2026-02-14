import { IsString, Matches, Length } from 'class-validator';

export class VerifyOtpDto {
  @IsString()
  @Length(10, 10, { message: 'mobileNumber must be 10 digits' })
  @Matches(/^[6-9]\d{9}$/, { message: 'Invalid Indian mobile number' })
  mobileNumber: string;

  @IsString()
  @Length(4, 4, { message: 'otp must be 4 digits' })
  @Matches(/^\d{4}$/, { message: 'otp must be 4 digits' })
  otp: string;
}
