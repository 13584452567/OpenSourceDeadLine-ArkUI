import {
  EventData,
  DeadlineItem,
  TimelineEvent,
  isEventEnded,
  nextUpcomingDeadline
} from '../common/model/DeadlineModels';
import { formatDeadline, formatTimelineDate } from '../common/utils/DateUtils';
import { openLinkAction, toggleFavoriteAction } from '../common/store/ActionBus';

interface TimeParts {
  days: number;
  hours: number;
  minutes: number;
  seconds: number;
}

@Component
export struct EventCard {
  @Prop item: DeadlineItem;
  @Prop event: EventData;
  @Prop isFavorited: boolean = false;
  @Prop nowTick: number | undefined = undefined;

  build() {
    Column({ space: 16 }) {
      // 顶部信息
      Column({ space: 8 }) {
        Row({ space: 12 }) {
          this.renderCategoryBadge(this.item.category);
          Row({ space: 4 }) {
            Text(this.item.title)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1F2937')
              .decoration({ type: TextDecorationType.Underline })
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .lineHeight(24)
              .layoutWeight(1)
          }
          .onClick(() => {
            openLinkAction(this.event.link);
          })
          .layoutWeight(1)
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')

        Row({ space: 8 }) {
          Text(`${this.event.year}`)
            .padding({
              left: 8,
              right: 8,
              top: 2,
              bottom: 2
            })
            .backgroundColor('#EFF6FF')
            .borderRadius(8)
            .fontSize(12)
            .fontColor('#1D4ED8')
          if (isEventEnded(this.event)) {
            Text('已结束')
              .padding({
                left: 8,
                right: 8,
                top: 2,
                bottom: 2
              })
              .backgroundColor('#F3F4F6')
              .borderRadius(8)
              .fontSize(12)
              .fontColor('#4B5563')
          }
          Blank()
          // 收藏按钮视觉统一：仅星形，尺寸与标签协调
          Button(this.isFavorited ? '★' : '☆')
            .type(ButtonType.Capsule)
            .fontColor(this.isFavorited ? '#B45309' : '#374151')
            .fontSize(18)
            .backgroundColor(this.isFavorited ? '#FFFBEB' : '#F3F4F6')
            .padding({
              left: 12,
              right: 12,
              top: 4,
              bottom: 4
            })
            .borderRadius(16)
            .border({ width: 0 })
            .onClick(() => {
              toggleFavoriteAction(`${this.event.id}`);
            })
            .accessibilityDescription(this.isFavorited ? '取消收藏' : '加入收藏')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text(this.item.description)
          .fontSize(14)
          .fontColor('#6B7280')
          .lineHeight(20)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      // 标签
      if (this.item.tags.length > 0) {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(this.item.tags, (tag: string) => {
            Text(tag)
              .fontSize(12)
              .fontColor('#1F2937')
              .padding({
                left: 12,
                right: 12,
                top: 6,
                bottom: 6
              })
              .backgroundColor('#F3F4F6')
              .borderRadius(16)
              .margin({ right: 8, bottom: 8 })
          }, (tag: string) => tag);
        }
      }

      // 基础信息
      Column({ space: 8 }) {
        this.renderInfoRow('举办时间', this.event.date);
        this.renderInfoRow('时区', this.event.timezone);
        this.renderInfoRow('地点', this.event.place);
      }

      // 时间线
      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Text('时间线')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          if (nextUpcomingDeadline(this.event) && !isEventEnded(this.event)) {
            Text(`下一截止：${formatDeadline(nextUpcomingDeadline(this.event)!.deadline)}`)
              .fontSize(12)
              .fontColor('#C2410C')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .alignItems(VerticalAlign.Center)

        // 横向滚动的时间线，避免超出屏幕
        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.event.timeline, (timelineEvent: TimelineEvent) => {
              this.renderTimelineItem(
                timelineEvent.comment,
                formatTimelineDate(timelineEvent.deadline),
                (nextUpcomingDeadline(this.event)?.deadline === timelineEvent.deadline),
                (!isEventEnded(this.event) && nextUpcomingDeadline(this.event)?.deadline !== timelineEvent.deadline &&
                  new Date(timelineEvent.deadline).getTime() > Date.now())
              );
            }, (timelineEvent: TimelineEvent) => timelineEvent.deadline);
          }
          .padding({
            left: 8,
            right: 8,
            top: 8,
            bottom: 8
          })
          .height('auto')
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
        .backgroundColor('#F9FAFB')
        .borderRadius(12)
        .border({ width: 1, color: '#E5E7EB' })
        .width('100%')
      }

      // 倒计时
      Column({ space: 8 }) {
        if (!isEventEnded(this.event) && nextUpcomingDeadline(this.event)) {
          Text('倒计时')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#9A3412')
          this.renderCountdown(nextUpcomingDeadline(this.event)!.deadline, this.nowTick)
        } else {
          Text('活动已结束')
            .fontSize(14)
            .fontColor('#6B7280')
            .padding({
              left: 12,
              right: 12,
              top: 8,
              bottom: 8
            })
            .backgroundColor('#F3F4F6')
            .borderRadius(12)
        }
      }
    }
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: '#0000000F',
      offsetX: 0,
      offsetY: 2
    })
    .opacity(isEventEnded(this.event) ? 0.65 : 1)
    .margin({ bottom: 16 })
  }

  @Builder
  private renderCategoryBadge(category: string) {
    Text(category === 'conference' ? '会议' :
      category === 'competition' ? '竞赛' : category === 'activity' ? '活动' : category)
      .fontSize(12)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFFFFF')
      .padding({
        left: 12,
        right: 12,
        top: 6,
        bottom: 6
      })
      .backgroundColor(
        category === 'conference'
          ? '#16A34A'
          : category === 'competition'
          ? '#DC2626'
          : category === 'activity'
            ? '#9333EA'
            : '#007AFF'
      )
      .borderRadius(12)
  }

  @Builder
  private renderInfoRow(label: string, value: string) {
    Row({ space: 8 }) {
      Text(label)
        .fontSize(13)
        .fontColor('#4B5563')
        .width(96)
      Text(value)
        .fontSize(13)
        .fontColor('#1F2937')
        .lineHeight(18)
        .maxLines(2)
        .textAlign(TextAlign.Start)
        .width('70%')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
  }

  @Builder
  private renderTimelineItem(title: string, date: string, active: boolean, upcoming: boolean) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(13)
        .fontColor('#1F2937')
        .lineHeight(18)
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .width(120)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(date)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(active ? '#C2410C' : upcoming ? '#2563EB' : '#6B7280')
        .textAlign(TextAlign.Center)
    }
    .padding({
      left: 12,
      right: 12,
      top: 12,
      bottom: 12
    })
    .backgroundColor(active ? '#FFF7ED' : upcoming ? '#EFF6FF' : '#FFFFFF')
    .borderRadius(12)
    .border({ width: active ? 2 : 1, color: active ? '#FDBA74' : '#E5E7EB' })
  }

  private isDeadlineExpired(deadline: string, nowTick?: number): boolean {
    const now = (typeof nowTick === 'number' && nowTick > 0) ? nowTick : Date.now();
    const ts = new Date(deadline).getTime();
    return isNaN(ts) || (ts - now) <= 0;
  }

  private timeParts(deadline: string, nowTick?: number): TimeParts {
    const now = (typeof nowTick === 'number' && nowTick > 0) ? nowTick : Date.now();
    const ts = new Date(deadline).getTime();
    const diffRaw = ts - now;
    const diff = Math.max(diffRaw, 0);
    const days = Math.floor(diff / 86400000);
    const hours = Math.floor((diff / 3600000) % 24);
    const minutes = Math.floor((diff / 60000) % 60);
    const seconds = Math.floor((diff / 1000) % 60);
    return {
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds
    };
  }

  @Builder
  private renderCountdown(deadline: string, nowTick?: number) {
    if (this.isDeadlineExpired(deadline, nowTick)) {
      Text('已过期')
        .fontColor('#DC2626')
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#FEE2E2')
        .borderRadius(8)
        .padding({
          left: 12,
          right: 12,
          top: 8,
          bottom: 8
        })
    } else {
      Row({ space: 8 }) {
        if (this.timeParts(deadline, nowTick).days > 0) {
          Column({ space: 4 }) {
            Text(this.timeParts(deadline, nowTick).days.toString().padStart(2, '0'))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .backgroundColor('#F97316')
              .borderRadius(8)
              .padding({
                left: 12,
                right: 12,
                top: 8,
                bottom: 8
              })
            Text('天').fontSize(12).fontColor('#C2410C').fontWeight(FontWeight.Medium)
          }
        }
        Column({ space: 4 }) {
          Text(this.timeParts(deadline, nowTick).hours.toString().padStart(2, '0'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor('#F97316')
            .borderRadius(8)
            .padding({
              left: 12,
              right: 12,
              top: 8,
              bottom: 8
            })
          Text('小时').fontSize(12).fontColor('#C2410C').fontWeight(FontWeight.Medium)
        }

        Column({ space: 4 }) {
          Text(this.timeParts(deadline, nowTick).minutes.toString().padStart(2, '0'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor('#F97316')
            .borderRadius(8)
            .padding({
              left: 12,
              right: 12,
              top: 8,
              bottom: 8
            })
          Text('分钟').fontSize(12).fontColor('#C2410C').fontWeight(FontWeight.Medium)
        }

        Column({ space: 4 }) {
          Text(this.timeParts(deadline, nowTick).seconds.toString().padStart(2, '0'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .backgroundColor('#F97316')
            .borderRadius(8)
            .padding({
              left: 12,
              right: 12,
              top: 8,
              bottom: 8
            })
          Text('秒').fontSize(12).fontColor('#C2410C').fontWeight(FontWeight.Medium)
        }
      }
    }
  }
}
