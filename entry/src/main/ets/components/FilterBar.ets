import { DeadlineItem } from '../common/model/DeadlineModels';

const CATEGORIES: Array<string> = ['conference', 'competition', 'activity'];
const TAG_PREVIEW_COUNT: number = 12;
const LOCATION_PREVIEW_COUNT: number = 10;

@Component
export struct FilterBar {
  @Prop items: Array<DeadlineItem> = [];
  @Link selectedCategory: string | null;
  @Link selectedTags: Array<string>;
  @Link selectedLocations: Array<string>;
  @Link searchQuery: string;
  @Link showOnlyFavorites: boolean;
  @State private tagsExpanded: boolean = false;
  @State private locationsExpanded: boolean = false;
  @State private showAdvanced: boolean = true;
  @State private pressedLabel: string = '';

  // ==== Data helpers ====
  private getCategoryDisplay(category: string): string {
    if (category === 'conference') { return '会议'; }
    if (category === 'competition') { return '竞赛'; }
    if (category === 'activity') { return '活动'; }
    return category;
  }
  private getCategoryLabel(category: string): string {
    return `${this.getCategoryDisplay(category)}(${this.getCategoryCount(category)})`;
  }
  private getCategoryCount(category: string): number {
    return this.items.filter(item => item.category === category).length;
  }

  private getAllTags(): Array<string> {
    return Array.from(new Set(this.items.flatMap(item => item.tags))).sort();
  }

  private getAllLocations(): Array<string> {
    return Array.from(new Set(this.items.flatMap(item => item.events.map(e => e.place)))).sort();
  }

  private getVisibleTags(): Array<string> {
    const tags = this.getAllTags();
    return this.tagsExpanded ? tags : tags.slice(0, TAG_PREVIEW_COUNT);
  }

  private getVisibleLocations(): Array<string> {
    const locs = this.getAllLocations();
    return this.locationsExpanded ? locs : locs.slice(0, LOCATION_PREVIEW_COUNT);
  }

  // ==== UI build ====
  build() {
    Column({ space: 12 }) {
      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索活动...' })
          .layoutWeight(1)
          .onChange((value) => {
            this.searchQuery = value;
          })
      }
      .padding(12)
      .borderRadius(12)
      .backgroundColor(Color.White)
      .width('100%')

      // 地点筛选
      Column() {
        Row() {
          Column() {
            Text('地点')
              .fontSize(14)
              .fontWeight(500)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          this.expandButton(this.locationsExpanded, () => this.locationsExpanded = !this.locationsExpanded)
        }
        .padding({ top: 12, bottom: 12 })
        .width('100%')

        if (this.locationsExpanded) {
          Divider().color('#F0F0F0').width('100%')
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
            ForEach(this.getVisibleLocations(), (location: string) => {
              this.chip(location, this.selectedLocations.includes(location), (): void => this.toggleLocation(location))
            }, (location: string) => location)
          }
          .width('100%')
          .padding(12)
        }
      }
      .padding({ left: 16, right: 16 })
      .borderRadius(12)
      .backgroundColor(Color.White)
      .width('100%')
      .animation({ duration: 200 })

      // 标签筛选
      Column() {
        Row() {
          Column() {
            Text('标签')
              .fontSize(14)
              .fontWeight(500)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          this.expandButton(this.tagsExpanded, () => this.tagsExpanded = !this.tagsExpanded)
        }
        .padding({ top: 12, bottom: 12 })
        .width('100%')

        if (this.tagsExpanded) {
          Divider().color('#F0F0F0').width('100%')
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
            ForEach(this.getVisibleTags(), (tag: string) => {
              this.chip(tag, this.selectedTags.includes(tag), (): void => this.toggleTag(tag))
            }, (tag: string) => tag)
          }
          .width('100%')
          .padding(12)
        }
      }
      .padding({ left: 16, right: 16 })
      .borderRadius(12)
      .backgroundColor(Color.White)
      .width('100%')
      .animation({ duration: 200 })
    }
    .padding(16)
    .backgroundColor('#F7F7F7')
  }

  // ==== Helpers ====
  private toggleTag(tag: string): void {
    this.toggleValue(this.selectedTags, tag);
  }

  private toggleLocation(location: string): void {
    this.toggleValue(this.selectedLocations, location);
  }

  private toggleValue(target: Array<string>, value: string) {
    const idx = target.indexOf(value);
    if (idx !== -1) {
      target.splice(idx, 1);
    } else {
      target.push(value);
    }
  }

  // ==== Reusable UI Builders ====
  @Builder
  private chip(label: string, active: boolean, onTap: () => void) {
    Button(label)
      .type(ButtonType.Capsule)
      .backgroundColor(active ? '#007AFF' : '#F9FAFB')
      .fontColor(active ? '#FFFFFF' : '#1F2937')
      .fontWeight(active ? FontWeight.Medium : FontWeight.Normal)
      .border({ width: 1, color: active ? '#007AFF' : '#E5E7EB' })
      .borderRadius(20)
      .margin({ right: 8, bottom: 8 })
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .scale({ x: (this.pressedLabel === label) ? 0.95 : 1, y: (this.pressedLabel === label) ? 0.95 : 1 })
      .animation({ duration: 150, curve: Curve.EaseInOut })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.pressedLabel = label;
        }
        if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.pressedLabel = '';
        }
      })
      .onClick(onTap)
  }

  @Builder
  private clearButton(onClick: () => void) {
    Button('清除')
      .type(ButtonType.Capsule)
      .fontSize(11)
      .backgroundColor('#F3F4F6')
      .fontColor('#374151')
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .onClick(onClick)
  }

  @Builder
  private expandButton(isExpanded: boolean, onClick: () => void) {
    Button(isExpanded ? '收起' : '更多')
      .type(ButtonType.Capsule)
      .fontSize(12)
      .backgroundColor('#FFFFFF')
      .fontColor('#374151')
      .border({ width: 1, color: '#E5E7EB' })
      .borderRadius(16)
      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
      .onClick(onClick)
  }

  @Builder
  private summaryBadge(label: string) {
    Text(label)
      .fontSize(12)
      .fontColor('#4B5563')
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor('#F3F4F6')
      .borderRadius(16)
      .margin({ right: 8, bottom: 8 })
  }

  @Builder
  private clearAllButton(onClick: () => void) {
    Button('清除全部')
      .type(ButtonType.Capsule)
      .fontSize(12)
      .backgroundColor('#FEE2E2')
      .fontColor('#B91C1C')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .onClick(onClick)
  }
}
