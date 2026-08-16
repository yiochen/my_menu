import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';
import 'package:mymenu/features/capture/capture_sheet.dart';
import 'package:mymenu/features/dish_detail/cook_again_sheet.dart';
import 'package:mymenu/features/dish_detail/dish_detail_content.dart';
import 'package:mymenu/features/dish_detail/dish_detail_hero.dart';
import 'package:mymenu/features/dish_detail/recipe_section_editor.dart';
import 'package:mymenu/features/photos/photos_route.dart';
import 'package:mymenu/features/photos/photos_screen.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/local_write_feedback.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

enum DishDetailTab { journal, recipe }

class DishDetailScreen extends StatefulWidget {
  const DishDetailScreen({required this.dishId, super.key});

  final String dishId;

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _dishOpened = false;
  late final TabController _tabController = TabController(
    length: DishDetailTab.values.length,
    vsync: this,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dishOpened) {
      return;
    }
    _dishOpened = true;
    final MyMenuState state = MyMenuScope.read(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(state.markDishOpened(widget.dishId));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish dish = state.dishById(widget.dishId);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double horizontal = MyMenuUnits.pageHorizontal(context);

    return Scaffold(
      body: WarmPage(
        includeBottomChromeSpace: false,
        topPadding: 0,
        bottomPadding: 0,
        horizontalPadding: 0,
        child: NestedScrollView(
          key: const ValueKey<String>('dish_detail_scroll_view'),
          headerSliverBuilder: (BuildContext context, bool innerScrolled) =>
              _headerSlivers(context, state, dish, mediaQuery, horizontal),
          body: TabBarView(
            key: const ValueKey<String>('dish_detail_page_view'),
            controller: _tabController,
            children: DishDetailTab.values.map((DishDetailTab tab) {
              return _DetailPage(
                key: ValueKey<String>('dish_detail_${tab.name}_page'),
                pageName: tab.name,
                horizontal: horizontal,
                bottom: mediaQuery.padding.bottom + 28,
                child: DishDetailContent(
                  dish: dish,
                  tab: tab,
                  onAddPhoto: () => _addPhoto(context, state, dish),
                  onAddNote: () => _addNote(context, state, dish),
                  onEditIngredients: () => _editRecipeSection(
                    context,
                    state,
                    dish,
                    ingredients: true,
                  ),
                  onEditSteps: () => _editRecipeSection(
                    context,
                    state,
                    dish,
                    ingredients: false,
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ),
      ),
    );
  }

  List<Widget> _headerSlivers(
    BuildContext context,
    MyMenuState state,
    Dish dish,
    MediaQueryData mediaQuery,
    double horizontal,
  ) {
    final GeneratedCover? automaticCover =
        state.unacknowledgedAutomaticCoverForDish(dish.id);
    return <Widget>[
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontal,
          mediaQuery.padding.top + 14,
          horizontal,
          0,
        ),
        sliver: SliverList.list(
          children: <Widget>[
            DishDetailHero(dish: dish),
            if (automaticCover != null) ...<Widget>[
              const SizedBox(height: 12),
              _AutomaticCoverNotice(
                cover: automaticCover,
                onUndo: () => state.undoAutomaticCover(automaticCover.id),
                onDismiss: () =>
                    state.acknowledgeAutomaticCover(automaticCover.id),
              ),
            ],
            const SizedBox(height: 16),
            PrimaryPillButton(
              key: const ValueKey<String>('cook_again_button'),
              label: 'Cook again',
              icon: Icons.play_arrow_rounded,
              onPressed: () => showCookAgainSheet(context, state, dish),
            ),
            const SizedBox(height: 12),
            _Metrics(dish: dish),
            const SizedBox(height: 12),
            _DetailTabs(controller: _tabController),
          ],
        ),
      ),
    ];
  }

  Future<void> _addPhoto(
    BuildContext context,
    MyMenuState state,
    Dish dish,
  ) async {
    final CaptureCompletion? completion = await showCaptureSheet(
      context,
      state,
      ImagePickerCaptureMediaService(),
      targetDishId: dish.id,
    );
    if (completion != CaptureCompletion.photosAdded || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    await Navigator.of(context).push<void>(
      photosRoute(
        initialFilter: PhotoFilter.all,
        reduceMotion: MediaQuery.disableAnimationsOf(context),
      ),
    );
  }

  Future<void> _addNote(
    BuildContext context,
    MyMenuState state,
    Dish dish,
  ) async {
    final String? note = await showAddNoteSheet(context);
    if (note != null && context.mounted) {
      await runLocalWriteWithFeedback(
        context,
        () => state.addDishNote(dish.id, note),
      );
    }
  }

  Future<void> _editRecipeSection(
    BuildContext context,
    MyMenuState state,
    Dish dish, {
    required bool ingredients,
  }) async {
    final List<String>? values = await showRecipeSectionEditor(
      context,
      title: ingredients ? 'Ingredients' : 'Steps',
      values: ingredients ? dish.ingredients : dish.recipeSteps,
    );
    if (values == null || !context.mounted) {
      return;
    }
    await runLocalWriteWithFeedback(
      context,
      () => state.updateDishSections(
        dish.id,
        ingredients: ingredients ? values : null,
        recipeSteps: ingredients ? null : values,
      ),
    );
  }
}

class _AutomaticCoverNotice extends StatelessWidget {
  const _AutomaticCoverNotice({
    required this.cover,
    required this.onUndo,
    required this.onDismiss,
  });

  final GeneratedCover cover;
  final VoidCallback onUndo;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => WarmCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            const Icon(Icons.auto_awesome, color: MyMenuColors.orange),
            const SizedBox(width: 10),
            const Expanded(child: Text('Your AI-improved cover is ready.')),
            TextButton(onPressed: onUndo, child: const Text('Undo')),
            IconButton(
              tooltip: 'Dismiss',
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      );
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({
    required this.pageName,
    required this.horizontal,
    required this.bottom,
    required this.child,
    super.key,
  });

  final String pageName;
  final double horizontal;
  final double bottom;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: PageStorageKey<String>('dish_detail_${pageName}_scroll_view'),
      padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, bottom),
      children: <Widget>[child],
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child:
                _Metric(value: '${dish.madeCount} cooks', label: 'occasions')),
        const SizedBox(width: 8),
        Expanded(
          child: _Metric(
            value: '${dish.sourcePhotos.length} photos',
            label: 'sources',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: _Metric(value: dish.lastMadeLabel, label: 'last made')),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      decoration: BoxDecoration(
        color: MyMenuColors.oat,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 3),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: MyMenuColors.oat,
        borderRadius: BorderRadius.circular(999),
      ),
      child: TabBar(
        key: const ValueKey<String>('dish_detail_tab_bar'),
        controller: controller,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x12302318),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        labelColor: MyMenuColors.ink,
        unselectedLabelColor: MyMenuColors.ink,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 11,
            ),
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        splashBorderRadius: BorderRadius.circular(999),
        tabs: const <Widget>[
          SizedBox(height: 36, child: Center(child: Text('Journal'))),
          SizedBox(height: 36, child: Center(child: Text('Recipe'))),
        ],
      ),
    );
  }
}
