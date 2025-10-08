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
  private getCategoryCount(category: string): number { let c=0; this.items.forEach(item=>{ if(item.category===category){c++;}}); return c; }
  private getAllTags(): Array<string> { return Array.from(new Set(this.items.flatMap(item => item.tags))).sort(); }
  private getAllLocations(): Array<string> { return Array.from(new Set(this.items.flatMap(item => item.events.map(e => e.place)))).sort(); }
  private getVisibleTags(): Array<string> { const tags=this.getAllTags(); return this.tagsExpanded?tags:tags.slice(0,TAG_PREVIEW_COUNT); }
  private getVisibleLocations(): Array<string> { const locs=this.getAllLocations(); return this.locationsExpanded?locs:locs.slice(0,LOCATION_PREVIEW_COUNT); }

  // ==== UI build ====
  build() {
    Column({ space: 16 }) {
      // 搜索框
      Column() {
        TextInput({ placeholder: '搜索活动、标签或地点…', text: this.searchQuery })
          .onChange((v: string): void => { this.searchQuery = v; })
          .placeholderColor('#9CA3AF')
          .backgroundColor('#F3F4F6')
          .borderRadius(24)
          .padding({ left: 20, right: 16, top: 10, bottom: 10 })
      }

      // 收藏 + 折叠开关
      Row({ space: 12 }) {
        Row({ space: 8 }) {
          Toggle({ type: ToggleType.Switch, isOn: this.showOnlyFavorites })
            .onChange((on: boolean): void => { this.showOnlyFavorites = on; })
          Text('只显示收藏').fontSize(14).fontColor('#4B5563')
        }.alignItems(VerticalAlign.Center)
        Blank()
        Button(this.showAdvanced ? '收起筛选 ▴' : '展开筛选 ▾')
          .type(ButtonType.Normal)
          .fontSize(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(18)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick((): void => { this.showAdvanced = !this.showAdvanced; })
      }.alignItems(VerticalAlign.Center)

      // 类别块
      if (this.showAdvanced) {
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Text('类别').fontSize(14).fontWeight(FontWeight.Medium)
            if (this.selectedCategory !== null) {
              Button('清除').type(ButtonType.Capsule).fontSize(11).backgroundColor('#F3F4F6').fontColor('#374151')
                .padding({ left: 10, right: 10 })
                .onClick((): void => { this.selectedCategory = null; })
            }
          }
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            this.chip('全部', this.selectedCategory === null, () => { this.selectedCategory = null; });
            ForEach(CATEGORIES, (c: string) => {
              this.chip(this.getCategoryLabel(c), this.selectedCategory === c, () => { this.selectedCategory = c; });
            }, (c: string) => c);
          }
        }

        // 地点
        if (this.getAllLocations().length > 0) {
          Column({ space: 8 }) {
            Row({ space: 8 }) {
              Text(`地点 (${this.selectedLocations.length}/${this.getAllLocations().length})`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
              if (this.selectedLocations.length > 0) {
                Button('清除')
                  .type(ButtonType.Capsule)
                  .fontSize(11)
                  .backgroundColor('#F3F4F6')
                  .fontColor('#374151')
                  .padding({ left: 10, right: 10 })
                  .onClick((): void => { this.selectedLocations.splice(0, this.selectedLocations.length); })
              }
              if (this.getAllLocations().length > LOCATION_PREVIEW_COUNT) {
                Button(this.locationsExpanded ? '收起' : '更多')
                  .type(ButtonType.Capsule)
                  .fontSize(12)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(16)
                  .padding({ left: 12, right: 12 })
                  .onClick((): void => { this.locationsExpanded = !this.locationsExpanded; })
              }
            }
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(this.getVisibleLocations(), (loc: string) => {
                this.chip(loc, this.selectedLocations.indexOf(loc) !== -1, () => { this.toggleValue(this.selectedLocations, loc); });
              }, (loc: string) => loc);
            }
          }
        }

        // 标签
        if (this.getAllTags().length > 0) {
          Column({ space: 8 }) {
            Row({ space: 8 }) {
              Text(`标签 (${this.selectedTags.length}/${this.getAllTags().length})`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
              if (this.selectedTags.length > 0) {
                Button('清除')
                  .type(ButtonType.Capsule)
                  .fontSize(11)
                  .backgroundColor('#F3F4F6')
                  .fontColor('#374151')
                  .padding({ left: 10, right: 10 })
                  .onClick((): void => { this.selectedTags.splice(0, this.selectedTags.length); })
              }
              if (this.getAllTags().length > TAG_PREVIEW_COUNT) {
                Button(this.tagsExpanded ? '收起' : '更多')
                  .type(ButtonType.Capsule)
                  .fontSize(12)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(16)
                  .padding({ left: 12, right: 12 })
                  .onClick((): void => { this.tagsExpanded = !this.tagsExpanded; })
              }
            }
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(this.getVisibleTags(), (tag: string) => {
                this.chip(tag, this.selectedTags.indexOf(tag) !== -1, () => { this.toggleValue(this.selectedTags, tag); });
              }, (tag: string) => tag);
            }
            if (!this.tagsExpanded && this.getAllTags().length > TAG_PREVIEW_COUNT) {
              Text(`已隐藏 ${this.getAllTags().length - TAG_PREVIEW_COUNT} 个标签，点击“更多”展开`)
                .fontSize(11)
                .fontColor('#6B7280')
            }
          }
        }
      } else {
        // 折叠摘要
        if (this.selectedCategory !== null || this.selectedTags.length > 0 || this.selectedLocations.length > 0) {
          Column({ space: 6 }) {
            Text('当前筛选')
              .fontSize(13)
              .fontColor('#374151')
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              // 类别
              if (this.selectedCategory !== null) {
                this.chip(this.getCategoryDisplay(this.selectedCategory), true, () => { this.selectedCategory = null; });
              }
              // 标签
              if (this.selectedTags.length > 0) {
                ForEach(this.selectedTags.slice(0, 5), (t: string) => {
                  this.chip(t, true, () => { this.toggleValue(this.selectedTags, t); });
                }, (t: string) => t);
                if (this.selectedTags.length > 5) {
                  Text(`+${this.selectedTags.length - 5}`)
                    .fontSize(12)
                    .fontColor('#6B7280')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                }
              }
              // 地点
              if (this.selectedLocations.length > 0) {
                ForEach(this.selectedLocations.slice(0, 3), (l: string) => {
                  this.chip(l, true, () => { this.toggleValue(this.selectedLocations, l); });
                }, (l: string) => l);
                if (this.selectedLocations.length > 3) {
                  Text(`+${this.selectedLocations.length - 3}`)
                    .fontSize(12)
                    .fontColor('#6B7280')
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                }
              }
              // 清除按钮
              if (this.selectedCategory !== null || this.selectedTags.length > 0 || this.selectedLocations.length > 0) {
                Button('清除全部')
                  .type(ButtonType.Capsule)
                  .fontSize(11)
                  .backgroundColor('#FEE2E2')
                  .fontColor('#B91C1C')
                  .padding({ left: 12, right: 12 })
                  .onClick((): void => {
                    this.selectedCategory = null;
                    this.selectedTags.splice(0, this.selectedTags.length);
                    this.selectedLocations.splice(0, this.selectedLocations.length);
                  })
              }
            }
          }
        }
      }
    }
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 6, color: '#00000014', offsetX: 0, offsetY: 1 })
  }

  // ==== Helpers ====
  private toggleValue(target: Array<string>, value: string) {
    const idx = target.indexOf(value);
    if (idx !== -1) { target.splice(idx, 1); } else { target.push(value); }
  }

  // ==== Chip Builder with animation feedback ====
  @Builder
  private chip(label: string, active: boolean, onTap: () => void) {
    Button(label)
      .type(ButtonType.Capsule)
      .backgroundColor(active ? '#007AFF' : '#FFFFFF')
      .fontColor(active ? '#FFFFFF' : '#1F2937')
      .fontWeight(active ? FontWeight.Medium : FontWeight.Normal)
      .border({ width: active ? 0 : 1, color: '#E5E7EB' })
      .borderRadius(20)
      .margin({ right: 8, bottom: 8 })
      .padding({ left: 16, right: 16 })
      .scale({ x: (this.pressedLabel === label) ? 0.92 : 1, y: (this.pressedLabel === label) ? 0.92 : 1 })
      .animation({ duration: 120, curve: Curve.EaseInOut })
      .onClick((): void => {
        this.pressedLabel = label;
        setTimeout(() => { if (this.pressedLabel === label) { this.pressedLabel = ''; } }, 140);
        onTap();
      })
  }
}
