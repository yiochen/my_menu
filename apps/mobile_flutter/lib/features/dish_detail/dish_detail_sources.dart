part of 'dish_detail_screen.dart';

void _showSourceGallery(
  BuildContext context,
  List<SourcePhoto> photos, {
  int initialIndex = 0,
}) {
  if (photos.isEmpty) {
    return;
  }

  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _SourceGallery(
        photos: photos,
        initialIndex: initialIndex,
      ),
    ),
  );
}

class _SourcePhotoStrip extends StatelessWidget {
  const _SourcePhotoStrip({required this.photos});

  final List<SourcePhoto> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const _EmptySources();
    }

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          return _SourcePhotoCard(
            photo: photos[index],
            isFirst: index == 0,
            onTap: () => _showSourceGallery(
              context,
              photos,
              initialIndex: index,
            ),
          );
        },
      ),
    );
  }
}

class _EmptySources extends StatelessWidget {
  const _EmptySources();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'No source photos yet',
        style: TextStyle(color: _detailMuted, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SourcePhotoCard extends StatelessWidget {
  const _SourcePhotoCard({
    required this.photo,
    required this.isFirst,
    required this.onTap,
  });

  final SourcePhoto photo;
  final bool isFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'View source photo from ${photo.capturedLabel}',
      child: SizedBox(
        width: 116,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              AppImage(imageRef: photo.url, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: <Color>[
                        Colors.black.withValues(alpha: 0.72),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    photo.capturedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (isFirst)
                const Positioned(left: 6, top: 6, child: _CoverBadge()),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onTap),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoverBadge extends StatelessWidget {
  const _CoverBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Current cover source',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _detailPaper.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.star, color: _detailGold, size: 14),
        ),
      ),
    );
  }
}

class _SourceGallery extends StatefulWidget {
  const _SourceGallery({required this.photos, required this.initialIndex});

  final List<SourcePhoto> photos;
  final int initialIndex;

  @override
  State<_SourceGallery> createState() => _SourceGalleryState();
}

class _SourceGalleryState extends State<_SourceGallery> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPage(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SourcePhoto photo = widget.photos[_index];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _detailInk,
        appBar: AppBar(
          backgroundColor: _detailInk,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: const CloseButton(),
          title: const Text(
            'Source Photos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          actions: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '${_index + 1} of ${widget.photos.length}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  PageView.builder(
                    controller: _controller,
                    itemCount: widget.photos.length,
                    onPageChanged: (int value) =>
                        setState(() => _index = value),
                    itemBuilder: (_, int index) => _GalleryImage(
                      photo: widget.photos[index],
                    ),
                  ),
                  if (_index > 0)
                    Positioned(
                      left: 12,
                      child: _GalleryArrow(
                        tooltip: 'Previous photo',
                        icon: Icons.chevron_left,
                        onPressed: () => _showPage(_index - 1),
                      ),
                    ),
                  if (_index < widget.photos.length - 1)
                    Positioned(
                      right: 12,
                      child: _GalleryArrow(
                        tooltip: 'Next photo',
                        icon: Icons.chevron_right,
                        onPressed: () => _showPage(_index + 1),
                      ),
                    ),
                ],
              ),
            ),
            _SourceDetails(photo: photo, isCover: _index == 0),
          ],
        ),
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({required this.photo});

  final SourcePhoto photo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Dish source photo from ${photo.capturedLabel}',
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: AppImage(
            imageRef: photo.url,
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

class _GalleryArrow extends StatelessWidget {
  const _GalleryArrow({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        backgroundColor: _detailPaper.withValues(alpha: 0.94),
        foregroundColor: _detailInk,
      ),
    );
  }
}

class _SourceDetails extends StatelessWidget {
  const _SourceDetails({required this.photo, required this.isCover});

  final SourcePhoto photo;
  final bool isCover;
  @override
  Widget build(BuildContext context) {
    final String? note = photo.note?.trim();
    final double maxPanelHeight =
        (MediaQuery.sizeOf(context).height * 0.42).clamp(180.0, 360.0);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 128, maxHeight: maxPanelHeight),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: _detailPaper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        primary: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.calendar_today, size: 18, color: _detailGold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    photo.capturedLabel,
                    style: const TextStyle(
                      color: _detailInk,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (isCover)
                  const Chip(
                    avatar: Icon(Icons.star, size: 16, color: _detailGold),
                    label: Text('Cover source'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (note != null && note.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                note,
                style: const TextStyle(
                  color: Color(0xFF36423C),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
