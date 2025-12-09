import { Controller, Post, Get, Body, UseGuards, Request } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { ScoresService } from './scores.service';
import { CreateScoreDto } from '../dto/create-score.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller()
export class ScoresController {
  constructor(private scoresService: ScoresService) {}

  @Post('scores')
  @UseGuards(JwtAuthGuard)
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  createScore(@Body() createScoreDto: CreateScoreDto, @Request() req) {
    return this.scoresService.createScore(createScoreDto, req.user.userId, req.user.isAdmin);
  }

  @Get('leaderboard')
  getLeaderboard() {
    return this.scoresService.getLeaderboard();
  }
}
