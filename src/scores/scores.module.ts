import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScoresService } from './scores.service';
import { ScoresController } from './scores.controller';
import { Score } from '../entities/score.entity';
import { User } from '../entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Score, User])],
  providers: [ScoresService],
  controllers: [ScoresController],
})
export class ScoresModule {}
