part of 'dish_detail_screen.dart';

class _DishStats extends StatelessWidget {
  const _DishStats({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatTile(
            icon: Icons.restaurant_menu,
            label: 'MADE',
            value: '${dish.madeCount} times',
          ),
        ),
        Expanded(
          child: _StatTile(
            icon: Icons.calendar_month,
            label: 'LAST MADE',
            value: dish.lastMadeLabel,
          ),
        ),
        Expanded(
          child: _StatTile(
            icon: Icons.schedule,
            label: 'TIME',
            value: '${dish.prepMinutes} min',
          ),
        ),
        Expanded(
          child: _StatTile(
            icon: Icons.signal_cellular_alt,
            label: 'LEVEL',
            value: dish.difficulty,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE8DFD1)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: _detailInk, size: 22),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _detailMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF1E2924),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
