import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { StandingsController } from './standings.controller';

@Module({
  imports: [AuthModule],
  controllers: [StandingsController],
})
export class StandingsModule {}
