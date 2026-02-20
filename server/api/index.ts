/// <reference types="express" />
import { NestFactory } from '@nestjs/core';
import { ExpressAdapter } from '@nestjs/platform-express';
import { AppModule } from '../src/app.module';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import express, { Request, Response } from 'express';
import { join } from 'path';

let cachedApp: express.Express;

async function createApp(): Promise<express.Express> {
  if (cachedApp) {
    return cachedApp;
  }

  const expressApp = express();
  const app = await NestFactory.create(AppModule, new ExpressAdapter(expressApp));

  const imagesPath = join(process.cwd(), 'public', 'images');
  
  // Secure CORS configuration - production vs development
  const isProduction = process.env.NODE_ENV === 'production';
  const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',').map((o) => o.trim()).filter(Boolean);
  const imageOrigins = isProduction
    ? (allowedOrigins || [])
    : '*';

  expressApp.use('/images', (req, res, next) => {
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
  expressApp.use('/images', express.static(imagesPath));

  const config = app.get(ConfigService);
  const prefix = config.get<string>('API_PREFIX', 'api');

  app.setGlobalPrefix(prefix);
  
  // Production: Only allow specific origins, Development: Allow all
  const corsOrigin = isProduction
    ? (allowedOrigins?.length ? allowedOrigins : []) // Production: strict
    : '*'; // Development: allow all
  
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

  await app.init();
  cachedApp = expressApp;
  return expressApp;
}

export default async function handler(req: Request, res: Response) {
  try {
    // Log request for debugging
    if (process.env.NODE_ENV !== 'production') {
      console.log('API Request:', req.method, req.url);
      console.log('Request path:', req.path);
      console.log('Request query:', req.query);
    }
    
    const app = await createApp();
    return app(req, res);
  } catch (error) {
    console.error('Handler error:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: process.env.NODE_ENV === 'production' 
        ? 'An error occurred' 
        : error instanceof Error ? error.message : 'Unknown error',
    });
  }
}
