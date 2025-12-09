import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn } from 'typeorm';
import { User } from './user.entity';

@Entity('scores')
export class Score {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  playerName: string;

  @Column()
  score: number;

  @ManyToOne(() => User, user => user.scores)
  user: User;

  @CreateDateColumn()
  createdAt: Date;
}
