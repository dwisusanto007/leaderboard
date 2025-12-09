import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class LoggerMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const startTime = Date.now();
    
    res.on('finish', () => {
      const duration = Date.now() - startTime;
      const logMessage = `${new Date().toISOString()} | IP: ${req.ip} | Method: ${req.method} | Endpoint: ${req.originalUrl} | Status: ${res.statusCode} | Duration: ${duration}ms\n`;
      
      const logsDir = path.join(process.cwd(), 'logs');
      if (!fs.existsSync(logsDir)) {
        fs.mkdirSync(logsDir);
      }
      
      const logFile = path.join(logsDir, 'requests.log');
      fs.appendFileSync(logFile, logMessage);
    });
    
    next();
  }
}
