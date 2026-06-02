import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { CalendarController } from './calendar.controller';

@Module({
  imports: [AuthModule],
  controllers: [CalendarController],
})
export class CalendarModule {}
