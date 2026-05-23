# Gemma 4 + Flutter Integration Scenarios 🚀

이 저장소는 구글의 차세대 오픈 가중치 언어 모델인 **Gemma 4**를 크로스플랫폼 프레임워크인 **Flutter**와 결합하여 모바일, 데스크톱 환경에서 구현할 수 있는 5가지 초/중급 실무 시나리오를 제공합니다.

저장소 구조는 사용자가 한 번에 클론하여 개별 시나리오의 코드 구조를 독립적으로 분석하고 나란히 학습할 수 있도록 **폴더별(Folder-based) 아키텍처**로 구성되어 있습니다.

---

## 📂 저장소 폴더 구조 (Directory Directory)

```text
.
├── README.md                          # [현재 파일] 전체 저장소 총괄 가이드
├── .gitignore                         # 공통 git ignore 규칙
├── 01_aura_diary/                     # 🌟 [완성] 시나리오 1: AI 일기 감정 분석 및 답장 (AuraDiary)
│   ├── lib/                           # AuraDiary Flutter 코드 전체
│   ├── test/                          # 위젯 및 로직 테스트 스위트
│   └── pubspec.yaml                   # 의존성 설정
├── 02_calendar_agent/                 # 📅 [예정] 시나리오 2: 자연어 일정 추출 스마트 비서
│   └── README.md                      # 개요 및 기술 명세서
├── 03_english_tutor/                  # ✈️ [예정] 시나리오 3: 오프라인 1:1 영어 회화 튜터
│   └── README.md                      # 개요 및 기술 명세서
├── 04_image_captioner/                # 🖼️ [예정] 시나리오 4: 온디바이스 스마트 이미지 갤러리 검색기
│   └── README.md                      # 개요 및 기술 명세서
└── 05_style_transformer/              # ✍️ [예정] 시나리오 5: AI 톤앤매너 텍스트 마스터
    └── README.md                      # 개요 및 기술 명세서
```

---

## 🌟 완성 시나리오: 01. AuraDiary (일기 감정 분석 및 답장기)

사용자의 하루 일기를 깊이 분석하여 5가지 감정(Aura: 기쁨, 슬픔, 분노, 평온, 설렘)으로 자동 센싱하고, 감정에 어울리는 테마 색상과 함께 Gemma 4가 생성한 공감 가득한 답장 및 실천 가이드를 전해주는 힐링 감성 일기장입니다.

### 1. 주요 아키텍처 특징
- **하이브리드 AI 지원**: 설정 화면에서 실시간으로 **Google AI Studio API 연동** 방식과 **로컬 온디바이스 Ollama(gemma4:e2b)** 연동 방식을 자유롭게 토글할 수 있습니다.
- **오프라인 모크 시뮬레이션**: 네트워크 연결이나 API 키가 등록되지 않았을 경우에도 앱이 절대 멈추지 않고, 정교하게 동작하는 마음 시뮬레이션 엔진이 작동하여 원활한 사용자 경험을 보장합니다.
- **Glassmorphic Cosmic Theme**: 네온 빛 테두리와 은은한 백그라운드 오라(BoxShadow Glow)를 적용한 하이엔드 다크 우주 테마를 제공합니다.
- **완전 무결 컴파일**: 최신 Flutter SDK 버전에서의 `BoxBorder` 및 `BoxShadow` 구조적 안정성을 100% 만족하며 정적 분석 경고 및 에러를 통과했습니다.

### 2. AuraDiary 시작하기 (Quick Start)
1. Flutter 환경이 조성되어 있는지 확인합니다.
2. `01_aura_diary` 디렉토리로 이동합니다.
   ```bash
   cd 01_aura_diary
   ```
3. 의존성 패키지를 내려받습니다.
   ```bash
   flutter pub get
   ```
4. 정적 분석 및 위젯 테스트를 실행하여 무결성을 확인합니다.
   ```bash
   flutter analyze
   flutter test
   ```
5. 기기 또는 시뮬레이터를 연결하고 앱을 실행합니다.
   ```bash
   flutter run
   ```

---

## 📅 후속 연동 시나리오 (02 ~ 05) 요약

### [02. 자연어 일정 추출 및 스마트 비서](02_calendar_agent/README.md)
- **핵심 기술**: LLM Tool Calling (Function Calling)
- **기능**: 사용자의 일상 언어("다음 주 목요일 3시에 미팅 잡아줘")에서 시간과 제목을 추출해 달력 이벤트에 자동 등록합니다.

### [03. 오프라인 1:1 영어 회화 튜터](03_english_tutor/README.md)
- **핵심 기술**: On-device LLM (양자화 GGUF 모델) 및 대화 메모리 윈도잉
- **기능**: 비행기 모드에서도 인공지능 영어 선생님이 맞춤형 롤플레잉 회화 대화 및 영어 첨삭을 제공합니다.

### [04. 온디바이스 스마트 이미지 갤러리 검색기](04_image_captioner/README.md)
- **핵심 기술**: Multimodal VLM (Gemma 4 Vision) 및 로컬 벡터 데이터베이스
- **기능**: 내 스마트폰 속 사진을 로컬에서 이미지 캡셔닝하여, 자연어로 사진을 쉽게 검색할 수 있도록 인덱싱합니다.

### [05. AI 톤앤매너 텍스트 마스터](05_style_transformer/README.md)
- **핵심 기술**: Few-Shot Prompting 스타일 주입
- **기능**: 날것의 아이디어 노트를 비즈니스 보고서체, 인스타 감성체 등 사용자가 원하는 5개 이상의 스타일로 즉각 변환 및 다국어 요약합니다.

---

## 🛡️ License & Contact
- **Author**: seungyongchoi
- **GitHub Remote Repository**: `git@github.com:likerberi/g4f.git`
