import { Injectable, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Score } from '../entities/score.entity';
import { User } from '../entities/user.entity';
import { CreateScoreDto } from '../dto/create-score.dto';

@Injectable()
export class ScoresService {
  constructor(
    @InjectRepository(Score)
    private scoreRepository: Repository<Score>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async createScore(createScoreDto: CreateScoreDto, userId: number, isAdmin: boolean) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    
    if (!isAdmin && user.username !== createScoreDto.playerName) {
      throw new ForbiddenException('You can only submit scores for yourself');
    }

    const score = this.scoreRepository.create({
      playerName: createScoreDto.playerName,
      score: createScoreDto.score,
      user,
    });

    return this.scoreRepository.save(score);
  }

  async getLeaderboard() {
    return this.scoreRepository.find({
      order: { score: 'DESC' },
      take: 10,
      select: ['playerName', 'score'],
    });
  }
}
