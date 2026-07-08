import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/planning/plan_dates.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/improve_cover/improve_cover_dialog.dart';
import 'package:mymenu/features/plan/plan_dish_dialog.dart';
import 'package:mymenu/shared/widgets/app_dialog.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

part 'dish_detail_editors.dart';
part 'dish_detail_note_dialog.dart';
part 'dish_detail_notes.dart';
part 'dish_detail_sections.dart';
part 'dish_detail_sources.dart';
part 'dish_detail_stats.dart';

const Color _detailInk = Color(0xFF153A2A);
const Color _detailMuted = Color(0xFF65706A);
const Color _detailPaper = Color(0xFFFFFCF7);
const Color _detailSurface = Color(0xFFF4EFE7);
const Color _detailGold = Color(0xFFC58A2E);
const double _dishHeroExpandedHeight = 328;

enum _DishDetailSection {
  notes,
  recipe,
  ingredients,
  sources,
}

class DishDetailScreen extends StatefulWidget {
  const DishDetailScreen({required this.dishId, super.key});

  final String dishId;

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _notesKey = GlobalKey();
  final GlobalKey _recipeKey = GlobalKey();
  final GlobalKey _ingredientsKey = GlobalKey();
  final GlobalKey _sourcesKey = GlobalKey();
  bool _isAppBarCollapsed = false;
  _DishDetailSection _activeSection = _DishDetailSection.notes;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollState);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollState)
      ..dispose();
    super.dispose();
  }

  void _updateScrollState() {
    if (!mounted) {
      return;
    }

    final double topInset = MediaQuery.paddingOf(context).top;
    final double collapseOffset =
        _dishHeroExpandedHeight - kToolbarHeight - topInset;
    final bool collapsed = _scrollController.offset >= collapseOffset;

    if (collapsed != _isAppBarCollapsed) {
      setState(() => _isAppBarCollapsed = collapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final Dish dish = state.dishById(widget.dishId);

    return Scaffold(
      backgroundColor: _detailSurface,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: state.refreshFromServer,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              _DishHero(dish: dish, collapsed: _isAppBarCollapsed),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: _detailPaper,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 42, 20, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _DishSummary(dish: dish),
                        const SizedBox(height: 18),
                        _DishStats(dish: dish),
                        const SizedBox(height: 18),
                        _JumpLinks(
                          activeSection: _activeSection,
                          onNotes: () => _scrollTo(
                            _notesKey,
                            _DishDetailSection.notes,
                          ),
                          onRecipe: () => _scrollTo(
                            _recipeKey,
                            _DishDetailSection.recipe,
                          ),
                          onIngredients: () => _scrollTo(
                            _ingredientsKey,
                            _DishDetailSection.ingredients,
                          ),
                          onSources: () => _scrollTo(
                            _sourcesKey,
                            _DishDetailSection.sources,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _NotesSection(key: _notesKey, dish: dish),
                        const SizedBox(height: 26),
                        _RecipeSection(key: _recipeKey, dish: dish),
                        const SizedBox(height: 26),
                        _IngredientsSection(key: _ingredientsKey, dish: dish),
                        const SizedBox(height: 26),
                        _SourcesSection(
                            key: _sourcesKey, photos: dish.sourcePhotos),
                        const SizedBox(height: 28),
                        _BottomActions(dish: dish),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollTo(GlobalKey key, _DishDetailSection section) {
    final BuildContext? context = key.currentContext;
    if (context == null) {
      return;
    }

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !_scrollController.hasClients) {
      return;
    }

    setState(() => _activeSection = section);

    final double topInset = MediaQuery.paddingOf(this.context).top;
    final double pinnedOffset = topInset + kToolbarHeight + 42;
    final double sectionTop = renderObject.localToGlobal(Offset.zero).dy;
    final double targetOffset =
        (_scrollController.offset + sectionTop - pinnedOffset).clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }
}

class _DishHero extends StatelessWidget {
  const _DishHero({required this.dish, required this.collapsed});

  final Dish dish;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return SliverAppBar(
      pinned: true,
      expandedHeight: _dishHeroExpandedHeight,
      stretch: true,
      backgroundColor: _detailPaper,
      surfaceTintColor: Colors.transparent,
      foregroundColor: collapsed ? _detailInk : Colors.white,
      systemOverlayStyle:
          collapsed ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      titleSpacing: 0,
      title: AnimatedOpacity(
        opacity: collapsed ? 1 : 0,
        duration: const Duration(milliseconds: 160),
        child: Text(
          dish.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      leadingWidth: 68,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: _HeroCircleButton(
          tooltip: 'Back',
          icon: Icons.arrow_back_ios_new,
          collapsed: collapsed,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      actions: <Widget>[
        _HeroCircleButton(
          tooltip: 'Favorite',
          onPressed: () => state.toggleFavorite(dish.id),
          icon: dish.isFavorite ? Icons.favorite : Icons.favorite_border,
          collapsed: collapsed,
        ),
        const SizedBox(width: 14),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AppImage(imageRef: dish.heroImageUrl, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 46,
              child: FilledButton.tonalIcon(
                onPressed: () =>
                    showImproveCoverDialog(context, state, dish.id),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Improve Cover'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.94),
                  foregroundColor: _detailInk,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  const _HeroCircleButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.collapsed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton.filled(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: collapsed
              ? const Color(0xFFECE5DA)
              : Colors.black.withValues(alpha: 0.38),
          foregroundColor: collapsed ? _detailInk : Colors.white,
          fixedSize: const Size.square(46),
        ),
      ),
    );
  }
}

class _DishSummary extends StatelessWidget {
  const _DishSummary({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          dish.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: _detailInk,
                fontSize: 30,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          dish.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF36423C),
                fontSize: 14,
                height: 1.35,
              ),
        ),
      ],
    );
  }
}
