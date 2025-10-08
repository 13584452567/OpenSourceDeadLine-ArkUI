interface TimeLeft {
  days: number;
  hours: number;
  minutes: number;
  seconds: number;
}

@Component
export struct CountdownTimer {
  @Prop deadline: string = '';
  @State timeLeft: TimeLeft | null = null;
  private timerId: number | undefined = undefined; // setTimeout id
  private active: boolean = false;
  private prevDeadline: string = '';
  private deadlineTs: number = 0;

  aboutToAppear() {
    this.start();
  }

  aboutToReuse() {
    // 当组件被复用（列表复用场景）时重新校准
    this.start();
  }

  aboutToDisappear() {
    this.stop();
  }

  build() {
    Row({ space: 12 }) {
      if (!this.timeLeft) {
        Text('已过期')
          .fontColor('#DC2626')
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#FEE2E2')
          .borderRadius(8)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      } else {
        if (this.timeLeft.days > 0) {
          this.renderSlot(this.timeLeft.days, '天');
        }
        this.renderSlot(this.timeLeft.hours, '小时');
        this.renderSlot(this.timeLeft.minutes, '分钟');
        this.renderSlot(this.timeLeft.seconds, '秒');
      }
    }
  }

  private start() {
    this.stop(); // 确保无残留
    this.prevDeadline = this.deadline;
    this.deadlineTs = new Date(this.deadline).getTime();
    this.active = true;
    this.updateTime();
    this.scheduleNext();
  }

  private stop() {
    this.active = false;
    if (this.timerId !== undefined) {
      clearTimeout(this.timerId);
      this.timerId = undefined;
    }
  }

  private scheduleNext() {
    if (!this.active) {
      return;
    }
    // 对齐到下一整秒，减少抖动
    const now = Date.now();
    const msToNext = 1000 - (now % 1000); // 0<ms<=1000
    this.timerId = setTimeout((): void => {
      // 如果 deadline 发生变化，重启
      if (this.deadline !== this.prevDeadline) {
        this.start();
        return;
      }
      this.updateTime();
      if (this.timeLeft) {
        this.scheduleNext();
      } else {
        this.stop();
      }
    }, msToNext);
  }

  private tickAndSchedule() {
    // no-op
  }

  @Builder
  private renderSlot(value: number, unit: string) {
    Column({ space: 4 }) {
      Text(value.toString().padStart(2, '0'))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#F97316')
        .borderRadius(8)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      Text(unit)
        .fontSize(12)
        .fontColor('#C2410C')
        .fontWeight(FontWeight.Medium)
    }
    .alignItems(HorizontalAlign.Center)
  }

  private updateTime() {
    const now = Date.now();
    if (this.deadline !== this.prevDeadline) {
      this.prevDeadline = this.deadline;
      this.deadlineTs = new Date(this.deadline).getTime();
    }
    const diffRaw = this.deadlineTs - now;
    if (isNaN(this.deadlineTs) || diffRaw <= 0) {
      this.timeLeft = null;
      return;
    }
    const diff = Math.max(diffRaw, 0);
    const days = Math.floor(diff / 86400000);
    const hours = Math.floor((diff / 3600000) % 24);
    const minutes = Math.floor((diff / 60000) % 60);
    const seconds = Math.floor((diff / 1000) % 60);
    this.timeLeft = { days, hours, minutes, seconds };
  }
}
