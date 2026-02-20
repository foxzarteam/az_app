import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import { NestExpressApplication } from '@nestjs/platform-express';
import { Request, Response, NextFunction } from 'express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  const config = app.get(ConfigService);
  const port = config.get<number>('PORT', 3000);
  const prefix = config.get<string>('API_PREFIX', 'api');

  const isProduction = process.env.NODE_ENV === 'production';
  const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',').map((o) => o.trim()).filter(Boolean);
  const imageOrigins = isProduction
    ? (allowedOrigins || [])
    : '*';

  app.use('/images', (req: Request, res: Response, next: NextFunction) => {
    if (isProduction && imageOrigins.length > 0 && imageOrigins !== '*') {
      const origin = req.headers.origin;
      if (origin && imageOrigins.includes(origin)) {
        res.header('Access-Control-Allow-Origin', origin);
      }
    } else {
      res.header('Access-Control-Allow-Origin', '*');
    }
    res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Accept');
    if (req.method === 'OPTIONS') {
      return res.sendStatus(200);
    }
    next();
  });
  app.useStaticAssets(join(process.cwd(), 'public', 'images'), {
    prefix: '/images/',
  });

  app.setGlobalPrefix(prefix);

  const corsOrigin = isProduction
    ? (allowedOrigins?.length ? allowedOrigins : []) // Production: strict
    : true; // Development: allow all
  
  app.enableCors({
    origin: corsOrigin,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: isProduction && allowedOrigins?.length ? true : false, // Only with specific origins
    allowedHeaders: ['Content-Type', 'Accept', 'Authorization'],
    exposedHeaders: ['Content-Type', 'Accept'],
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false, // Allow extra fields
      transform: true,
      transformOptions: { enableImplicitConversion: true },
      stopAtFirstError: false,
    }),
  );

  await app.listen(port);
  if (process.env.NODE_ENV !== 'production') {
    console.log(`Bankers API running at http://localhost:${port}/${prefix}`);
  }
}

bootstrap().catch((err) => {
  console.error('Bootstrap failed:', err);
  process.exit(1);
});
