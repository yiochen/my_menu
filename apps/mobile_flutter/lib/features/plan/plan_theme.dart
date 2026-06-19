import 'package:flutter/material.dart';

class PlanThemeTokens extends ThemeExtension<PlanThemeTokens> {
  const PlanThemeTokens({
    // Overall Plan screen spacing.
    this.screenTopPadding = 24,
    this.screenBottomPadding = 150,
    this.sectionSpacing = 20,
    this.subsectionSpacing = 12,
    this.reviewSpacing = 16,

    // Day planner card and left date rail.
    this.cardRadius = 24,
    this.dayColumnWidth = 40,
    this.dayColumnGap = 8,
    this.dayRowSpacing = 16,
    this.dayCardPadding = const EdgeInsets.all(12),
    this.dayDividerPadding = const EdgeInsets.symmetric(vertical: 10),
    this.mealToAddSpacing = 8,
    this.dateHeaderSpacing = 8,
    this.dateDotSpacing = 12,
    this.dateDayFontSize = 16,
    this.dateWeekdayFontSize = 7,
    this.dateDotSize = 8,
    this.dishThumbWidth = 80,
    this.dishThumbHeight = 80,
    this.dishRowRadius = 18,
    this.dishRowInset = const EdgeInsets.all(2),
    this.dishThumbRadius = 14,
    this.dishContentGap = 10,
    this.dishMetaSpacing = 6,
    this.dishLabelGap = 12,
    this.dragPlaceholderHeight = 12,
    this.emptyDayDropHeight = 88,
    this.emptyDayDropHoverHeight = 110,
    this.addButtonHeight = 40,
    this.addButtonRadius = 16,
    this.labelChipPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    this.labelChipRadius = 999,
    this.labelFontSize = 10,
    this.dragSlotRadius = 18,
    this.dragShadeColor = const Color(0xB3FFFFFF),
    this.dragTrashSize = 60,
    this.dragTrashIconSize = 26,
    this.dragTrashRightOffset = 18,
    this.dragAutoScrollTrigger = 140,
    this.dragAutoScrollStep = 20,
    this.dragSlotIconSize = 18,
    this.dragGapAnimationDuration = const Duration(milliseconds: 180),
    this.dragGapAnimationCurve = Curves.easeOutCubic,

    // Top header with the title and action buttons.
    this.headerTitleSpacing = 10,
    this.headerSubtitleSpacing = 4,
    this.headerActionSpacing = 12,
    this.headerButtonRadius = 18,
    this.headerButtonSize = 52,
    this.headerButtonIconSize = 21,

    // "Cook Tonight?" recommendation card.
    this.cookTonightCardRadius = 24,
    this.cookTonightCardPadding = const EdgeInsets.all(12),
    this.cookTonightHeaderIconSize = 19,
    this.cookTonightHeaderSpacing = 12,
    this.cookTonightTitleFontSize = 14,
    this.cookTonightBlurbTopSpacing = 8,
    this.cookTonightBlurbLeftInset = 33,
    this.cookTonightBlurbWidth = 141,
    this.cookTonightSuggestionTopSpacing = 16,
    this.cookTonightSuggestionPadding = const EdgeInsets.all(8),
    this.cookTonightSuggestionRadius = 22,
    this.cookTonightSuggestionThumbRadius = 14,
    this.cookTonightSuggestionThumbWidth = 80,
    this.cookTonightSuggestionThumbHeight = 80,
    this.cookTonightSuggestionGap = 10,
    this.cookTonightSuggestionMetaSpacing = 6,
    this.cookTonightSuggestionMetaFontSize = 10,
    this.cookTonightBookmarkSize = 20,

    // Review prompt card shown below the planner when needed.
    this.reviewCardRadius = 24,

    // "From your menu" horizontal strip.
    this.menuHeadingFontSize = 14,
    this.menuHeaderToListSpacing = 8,
    this.menuCardHeight = 100,
    this.menuCardGap = 10,
    this.menuCardWidth = 100,
    this.menuCardRadius = 16,
    this.menuImageHeight = 80,
    this.menuTitlePadding = const EdgeInsets.fromLTRB(8, 24, 8, 8),
    this.menuCardTitleFontSize = 10,
  });

  // Overall Plan screen spacing.
  final double screenTopPadding;
  final double screenBottomPadding;
  final double sectionSpacing;
  final double subsectionSpacing;
  final double reviewSpacing;

  // Day planner card and left date rail.
  final double cardRadius;
  final double dayColumnWidth;
  final double dayColumnGap;
  final double dayRowSpacing;
  final EdgeInsets dayCardPadding;
  final EdgeInsets dayDividerPadding;
  final double mealToAddSpacing;
  final double dateHeaderSpacing;
  final double dateDotSpacing;
  final double dateDayFontSize;
  final double dateWeekdayFontSize;
  final double dateDotSize;
  final double dishThumbWidth;
  final double dishThumbHeight;
  final double dishRowRadius;
  final EdgeInsets dishRowInset;
  final double dishThumbRadius;
  final double dishContentGap;
  final double dishMetaSpacing;
  final double dishLabelGap;
  final double dragPlaceholderHeight;
  final double emptyDayDropHeight;
  final double emptyDayDropHoverHeight;
  final double addButtonHeight;
  final double addButtonRadius;
  final EdgeInsets labelChipPadding;
  final double labelChipRadius;
  final double labelFontSize;
  final double dragSlotRadius;
  final Color dragShadeColor;
  final double dragTrashSize;
  final double dragTrashIconSize;
  final double dragTrashRightOffset;
  final double dragAutoScrollTrigger;
  final double dragAutoScrollStep;
  final double dragSlotIconSize;
  final Duration dragGapAnimationDuration;
  final Curve dragGapAnimationCurve;

  // Top header with the title and action buttons.
  final double headerTitleSpacing;
  final double headerSubtitleSpacing;
  final double headerActionSpacing;
  final double headerButtonRadius;
  final double headerButtonSize;
  final double headerButtonIconSize;

  // "Cook Tonight?" recommendation card.
  final double cookTonightCardRadius;
  final EdgeInsets cookTonightCardPadding;
  final double cookTonightHeaderIconSize;
  final double cookTonightHeaderSpacing;
  final double cookTonightTitleFontSize;
  final double cookTonightBlurbTopSpacing;
  final double cookTonightBlurbLeftInset;
  final double cookTonightBlurbWidth;
  final double cookTonightSuggestionTopSpacing;
  final EdgeInsets cookTonightSuggestionPadding;
  final double cookTonightSuggestionRadius;
  final double cookTonightSuggestionThumbRadius;
  final double cookTonightSuggestionThumbWidth;
  final double cookTonightSuggestionThumbHeight;
  final double cookTonightSuggestionGap;
  final double cookTonightSuggestionMetaSpacing;
  final double cookTonightSuggestionMetaFontSize;
  final double cookTonightBookmarkSize;

  // Review prompt card shown below the planner when needed.
  final double reviewCardRadius;

  // "From your menu" horizontal strip.
  final double menuHeadingFontSize;
  final double menuHeaderToListSpacing;
  final double menuCardHeight;
  final double menuCardGap;
  final double menuCardWidth;
  final double menuCardRadius;
  final double menuImageHeight;
  final EdgeInsets menuTitlePadding;
  final double menuCardTitleFontSize;

  @override
  PlanThemeTokens copyWith() => this;

  @override
  PlanThemeTokens lerp(
    covariant ThemeExtension<PlanThemeTokens>? other,
    double t,
  ) {
    if (other is! PlanThemeTokens) {
      return this;
    }

    return t < 0.5 ? this : other;
  }
}

extension PlanThemeBuildContext on BuildContext {
  PlanThemeTokens get planTheme => Theme.of(this).extension<PlanThemeTokens>()!;
}
