import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/gallery_image.dart';
import '../providers/gallery_provider.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Parse color hex helper
  Color _parseColor(String hex, {double opacity = 1.0}) {
    try {
      final cleanHex = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16)).withOpacity(opacity);
    } catch (_) {
      return Colors.white.withOpacity(opacity);
    }
  }

  // Prompt to add media
  void _showAddMediaSheet(BuildContext context, GalleryProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161623),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '사진 추가하기',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '인공지능 비전 모델이 분석할 사진을 가져옵니다.',
                style: TextStyle(color: Color(0xFF72757A), fontSize: 13),
              ),
              const SizedBox(height: 20),
              
              // 1. Pick from Gallery
              _buildBottomSheetItem(
                icon: Icons.photo_library_rounded,
                color: const Color(0xFF7F5AF0),
                title: '디바이스 갤러리에서 선택',
                subtitle: '여러 장의 사진을 한 번에 가져와 배치 분석할 수 있습니다.',
                onTap: () async {
                  Navigator.pop(context);
                  final List<XFile> pickedFiles = await _picker.pickMultiImage();
                  if (pickedFiles.isNotEmpty) {
                    provider.addImagesToQueue(pickedFiles);
                  }
                },
              ),
              const SizedBox(height: 12),
              
              // 2. Take a photo
              _buildBottomSheetItem(
                icon: Icons.camera_alt_rounded,
                color: const Color(0xFF2CB67D),
                title: '새로 카메라 촬영',
                subtitle: '지금 즉시 사진을 촬영하여 AI 캡션을 생성합니다.',
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    provider.addImagesToQueue([pickedFile]);
                  }
                },
              ),
              const SizedBox(height: 12),
              
              // 3. Load Sample Demo Set
              _buildBottomSheetItem(
                icon: Icons.auto_awesome_rounded,
                color: const Color(0xFFF15BB5),
                title: '데모 샘플 이미지 5종 가져오기',
                subtitle: '인터넷 고품질 샘플 이미지를 인덱싱하여 검색을 바로 시험합니다.',
                onTap: () {
                  Navigator.pop(context);
                  provider.importSampleImages();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for sheet options
  Widget _buildBottomSheetItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF94A1B2), fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white30),
          ],
        ),
      ),
    );
  }

  // Show detailed image viewer bottom sheet
  void _showImageDetail(BuildContext context, GalleryImage image, GalleryProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF07070F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                // Fetch the latest version of this image from provider in case it got updated
                final currentImages = provider.isSearching ? provider.searchResults : provider.images;
                final img = currentImages.firstWhere((element) => element.id == image.id, orElse: () => image);

                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Header Drag line
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 1. Rounded Media Container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: img.isSample
                              ? Image.network(
                                  img.imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.white10,
                                    child: const Icon(Icons.broken_image_rounded, color: Colors.white30, size: 48),
                                  ),
                                )
                              : Image.file(
                                  File(img.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.white10,
                                    child: const Icon(Icons.broken_image_rounded, color: Colors.white30, size: 48),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Search Match details if relevant
                      if (provider.isSearching && img.searchScore > 0.0) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2CB67D).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF2CB67D)),
                              ),
                              child: Text(
                                '${(img.searchScore * 100).toInt()}% 일치',
                                style: const TextStyle(color: Color(0xFF2CB67D), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('자연어 매칭 점수', style: TextStyle(color: Color(0xFF72757A), fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 2. AI Caption Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161623),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      img.isPending ? Icons.sync_rounded : Icons.auto_awesome_rounded,
                                      color: const Color(0xFF7F5AF0),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Gemma 4 Vision 묘사',
                                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, color: Colors.white54, size: 18),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: img.caption));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('클립보드에 묘사 텍스트가 복사되었습니다.'),
                                        backgroundColor: const Color(0xFF7F5AF0),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              img.caption,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Keywords/Tags Section
                      const Text(
                        '색인된 키워드 태그',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: img.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Text(
                            '# $tag',
                            style: const TextStyle(color: Color(0xFF94A1B2), fontSize: 13),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 32),

                      // 4. File Info Metadata
                      const Text(
                        '파일 메타데이터',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildMetaRow('색인 날짜', img.dateAdded.toLocal().toString().substring(0, 19)),
                      _buildMetaRow('파일 위치', img.isSample ? '원격 서버 (Unsplash)' : '어플리케이션 도큐먼트 디렉토리'),
                      _buildMetaRow('이미지 경로', img.imagePath),
                      
                      const SizedBox(height: 40),
                      Divider(color: Colors.white.withOpacity(0.06)),
                      const SizedBox(height: 20),

                      // 5. Interactive Operations
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: img.isPending
                                  ? null
                                  : () async {
                                      await provider.reanalyzeImage(img.id);
                                      setModalState(() {});
                                    },
                              icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                              label: const Text('AI 다시 분석', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7F5AF0).withOpacity(0.12),
                                surfaceTintColor: Colors.transparent,
                                side: const BorderSide(color: Color(0xFF7F5AF0)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: img.isPending
                                  ? null
                                  : () => _editCaptionDialog(context, img, provider, setModalState),
                              icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                              label: const Text('수동 편집', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.05),
                                side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            provider.deleteImage(img.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('이미지가 갤러리에서 삭제되었습니다.'),
                                backgroundColor: const Color(0xFFFF4E50),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF4E50), size: 18),
                          label: const Text('갤러리에서 영구 제거', style: TextStyle(color: Color(0xFFFF4E50), fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Dialog to edit caption manually
  void _editCaptionDialog(BuildContext context, GalleryImage image, GalleryProvider provider, StateSetter setModalState) {
    final TextEditingController captionEditController = TextEditingController(text: image.caption);
    final TextEditingController tagsEditController = TextEditingController(text: image.tags.join(', '));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161623),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        title: const Text('설명 및 태그 직접 편집', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('설명 묘사', style: TextStyle(color: Color(0xFF94A1B2), fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  controller: captionEditController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('태그 (쉼표로 구분)', style: TextStyle(color: Color(0xFF94A1B2), fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  controller: tagsEditController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소', style: TextStyle(color: Color(0xFF94A1B2))),
          ),
          ElevatedButton(
            onPressed: () {
              final newCaption = captionEditController.text.trim();
              final List<String> newTags = tagsEditController.text
                  .split(',')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .toList();
              
              provider.updateCaptionManually(image.id, newCaption, newTags);
              Navigator.pop(ctx);
              
              // Force update modal view state
              setModalState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7F5AF0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('수정 저장', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Row creator for metadata table
  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF72757A), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF94A1B2), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GalleryProvider>(context);
    final displayedList = provider.isSearching ? provider.searchResults : provider.images;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Cosmic Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0B26), // Cosmic deep purple
                  Color(0xFF07070F), // Absolute deep black
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // 2. Subtle glowing background auras
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7F5AF0).withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF15BB5).withOpacity(0.06),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          // 3. Scrollable App Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GemmaLens',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    Color(0xFF7F5AF0),
                                    Color(0xFFF15BB5),
                                  ],
                                ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '온디바이스 비전 캡셔닝 & 스마트 이미지 검색',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF72757A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Settings Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Real-time Search Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      onChanged: (val) => provider.search(val),
                      decoration: InputDecoration(
                        hintText: '"바닷가", "강아지", "일출 산" 등으로 검색...',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.cancel_rounded, color: Colors.white54),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.search('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Background Worker Progress Dashboard Card
                if (provider.isBackgroundWorkerRunning) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F5AF0).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF7F5AF0).withOpacity(0.25)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF7F5AF0),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '⚡ AI 백그라운드 인덱서 작동 중 (남은 사진: ${provider.pendingCount}장)',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              minHeight: 4,
                              backgroundColor: Colors.white10,
                              color: Color(0xFF7F5AF0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Grid or Empty State
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF7F5AF0)))
                      : displayedList.isEmpty
                          ? _buildEmptyState(provider)
                          : GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.76,
                              ),
                              itemCount: displayedList.length,
                              itemBuilder: (context, index) {
                                final img = displayedList[index];
                                return _buildImageCard(img, provider);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMediaSheet(context, provider),
        backgroundColor: const Color(0xFF7F5AF0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
      ),
    );
  }

  // Grid Image Card Builder
  Widget _buildImageCard(GalleryImage img, GalleryProvider provider) {
    return GestureDetector(
      onTap: () => _showImageDetail(context, img, provider),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161623),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: img.isPending
                ? const Color(0xFF7F5AF0).withOpacity(0.3)
                : Colors.white.withOpacity(0.06),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  img.isSample
                      ? Image.network(
                          img.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.white10,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_rounded, color: Colors.white30),
                          ),
                        )
                      : Image.file(
                          File(img.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.white10,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_rounded, color: Colors.white30),
                          ),
                        ),
                  
                  // Score Badge if searching
                  if (provider.isSearching && img.searchScore > 0.0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2CB67D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${(img.searchScore * 100).toInt()}% 매칭',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Pending / Scanning Overlay
                  if (img.isPending)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF7F5AF0),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'AI 분석 중...',
                            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Text Details Area
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption
                  Text(
                    img.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // First 2 Tags
                  Row(
                    children: img.tags.take(2).map((tag) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Text(
                          '#$tag',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF94A1B2), fontSize: 10),
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty State Widget
  Widget _buildEmptyState(GalleryProvider provider) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161623),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(
              Icons.image_search_rounded,
              color: Color(0xFF7F5AF0),
              size: 72,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '인덱싱된 이미지가 없습니다',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '기기 속 사진을 추가하면 Gemma 4가 이미지 내용을 \n자동으로 분석하여 묘사문과 태그를 작성해 줍니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF94A1B2),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          
          // Seed samples button
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7F5AF0), Color(0xFFF15BB5)],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ElevatedButton.icon(
              onPressed: () => provider.importSampleImages(),
              icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              label: const Text(
                '데모 샘플 이미지 5종 가져오기',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
