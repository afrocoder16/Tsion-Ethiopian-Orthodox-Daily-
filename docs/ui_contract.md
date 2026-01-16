Screen: Today

Object: TodayHeader
- title: String
- greeting: String
- dateText: String
- calendarLabel: String

Object: HeaderAction
- iconKey: String

Object: VerseCard
- id: String
- title: String
- reference: String
- body: String

Object: VerseActionStat
- iconKey: String
- label: String

Object: AudioCard
- id: String
- title: String
- subtitle: String
- durationText: String

Object: MemoryCue
- text: String

Object: SectionHeader
- title: String
- subtitle: String (optional)
- showSeeAll: Bool (optional)

Object: TodayCarouselItem
- id: String
- title: String
- subtitle: String

Screen: Books

Object: ReadingStreakBadge
- label: String
- compact: Bool (optional)

Object: SearchBar
- placeholder: String

Object: BooksFilterOption
- text: String
- value: String

Object: FilterSelection
- selected: String

Object: SectionHeader
- title: String
- subtitle: String (optional)
- showSeeAll: Bool (optional)

Object: BookItem
- id: String
- title: String
- subtitle: String (optional)

Object: PatronSaintCard
- id: String
- label: String
- name: String

Object: ContinueReadingAction
- label: String
- progressText: String (optional)

Screen: Prayers

Object: PrayersTopBar
- title: String

Object: StreakIcon
- isActive: Bool

Object: PrimaryPrayerCard
- id: String
- label: String
- title: String
- subtitle: String
- actionLabel: String

Object: SectionHeader
- title: String
- subtitle: String (optional)
- showSeeAll: Bool (optional)

Object: DevotionalItem
- id: String
- title: String
- subtitle: String
- iconKey: String

Object: PrayerTile
- title: String

Object: RecentLine
- text: String

Screen: Calendar

Object: CalendarTopBar
- title: String
- subtitle: String

Object: MonthSelectorItem
- label: String

Object: TodayStatusCard
- ethiopianDate: String
- gregorianDate: String

Object: SignalItem
- label: String
- value: String

Object: ObservanceItem
- type: String
- label: String

Object: ActionItem
- label: String
- iconKey: String

Object: SectionHeader
- title: String
- subtitle: String (optional)
- showSeeAll: Bool (optional)

Object: UpcomingDay
- id: String
- date: String
- saint: String
- label: String

Object: DayDetail
- date: String
- gregorianDate: String
- bahireTitle: String
- bahireDescription: String
- links: List<LinkTile>

Object: LinkTile
- label: String

Screen: Explore

Object: ExploreTopBar
- title: String
- subtitle: String

Object: SectionHeader
- title: String
- subtitle: String (optional)
- showSeeAll: Bool (optional)

Object: ExploreCardItem
- id: String
- title: String
- subtitle: String

Object: SmallTile
- title: String

Object: CategoryChip
- label: String

Object: ExploreContentItem
- id: String
- title: String
- category: String

Object: SavedItem
- id: String
- title: String
