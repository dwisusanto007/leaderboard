import { IsString, IsNumber, Min } from 'class-validator';

export class CreateScoreDto {
  @IsString()
  playerName: string;

  @IsNumber()
  @Min(0)
  score: number;
}
