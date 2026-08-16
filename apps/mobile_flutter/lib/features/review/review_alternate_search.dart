import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class AlternateDishSearch extends StatelessWidget {
  const AlternateDishSearch({
    required this.state,
    required this.query,
    required this.onQueryChanged,
    required this.onBack,
    required this.onSelect,
    required this.onMakeNew,
    super.key,
  });

  final MyMenuState state;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onBack;
  final ValueChanged<Dish> onSelect;
  final VoidCallback onMakeNew;

  @override
  Widget build(BuildContext context) {
    final List<Dish> matches = state.filterDishes(query);
    return WarmPage(
      includeBottomChromeSpace: false,
      topPadding: 10,
      child: Column(
        children: <Widget>[
          _AlternateHeader(onBack: onBack),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: query,
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              suffixIcon: Icon(Icons.close),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: matches.isEmpty
                ? _NoMatches(onClear: () => onQueryChanged(''))
                : ListView.separated(
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final Dish dish = matches[index];
                      return ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        title: Text(dish.title),
                        subtitle: Text('${dish.madeCount} times made'),
                        onTap: () => onSelect(dish),
                      );
                    },
                  ),
          ),
          _MakeNewCard(onMakeNew: onMakeNew),
        ],
      ),
    );
  }
}

class _AlternateHeader extends StatelessWidget {
  const _AlternateHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleIconButton(
          icon: Icons.arrow_back_ios_new,
          size: 40,
          radius: 14,
          onPressed: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Item 1 of 2', style: Theme.of(context).textTheme.bodySmall),
              Text(
                'Choose a different dish',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MakeNewCard extends StatelessWidget {
  const _MakeNewCard({required this.onMakeNew});

  final VoidCallback onMakeNew;

  @override
  Widget build(BuildContext context) {
    return WarmCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            backgroundColor: MyMenuColors.orangeSoft,
            child: Icon(Icons.add, color: MyMenuColors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('None of these?',
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  'Start a new dish from this capture.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onMakeNew, child: const Text('Make new')),
        ],
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            color: MyMenuColors.orangeSoft,
            borderRadius: BorderRadius.circular(38),
          ),
          child: const Icon(
            Icons.search_off,
            size: 50,
            color: MyMenuColors.orange,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No matching dish',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Try “salmon,” clear the search to browse your menu, or make this '
          'capture a new dish.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 150,
          child: PrimaryPillButton(
            label: 'Clear search',
            onPressed: onClear,
            backgroundColor: MyMenuColors.oat,
            foregroundColor: MyMenuColors.ink,
          ),
        ),
      ],
    );
  }
}
