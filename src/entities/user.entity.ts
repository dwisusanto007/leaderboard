import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from 'typeorm';
import { Score } from './score.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  username: string;

  @Column()
  password: string;

  @Column({ default: false })
  isAdmin: boolean;

  @OneToMany(() => Score, score => score.user)
  scores: Score[];
}
