# Scenario 2: 자연어 일정 추출 및 스마트 비서 (Natural Language Calendar & Tasks Agent)

## 💡 개요
사용자가 구어체로 끄적인 일상 문장에서 일시, 시간, 장소, 제목을 Gemma 4를 통해 자동으로 추출하고 구조화된 JSON 데이터로 파싱하여 앱 내 달력에 일정을 즉시 추가해 주는 스마트 캘린더 비서 앱입니다.

---

## 🛠️ 주요 기술 스펙
- **Tool Calling (Function Calling)**: Gemma 4의 도구 호출 기능을 통해 구어체 텍스트로부터 사전에 정의된 `add_calendar_event` 함수에 들어갈 아규먼트(`title`, `date`, `time`, `location`)를 구조화된 JSON으로 안전하게 추출합니다.
- **Flutter Table Calendar & Local DB**: 파싱된 이벤트 데이터를 플러터 캘린더 위젯(예: `table_calendar`)에 실시간 연동하고 로컬 SQLite 또는 Hive에 저장합니다.

---

## 🚀 아키텍처 및 데이터 흐름
```text
사용자 입력 ("내일 아침 10시 강남역 미팅") 
  ➡️ Gemma 4 (시스템 프롬프트 & 함수 스펙 제공)
  ➡️ 구조화된 JSON 결과 반환:
     {
       "title": "강남역 미팅",
       "date": "2026-05-24",
       "time": "10:00",
       "location": "강남역"
     }
  ➡️ Flutter Provider / Repository 
  ➡️ 달력 화면 실시간 추가 및 알림 스케줄링
```

---

## 📅 로드맵 및 도전 과제
1. **정교한 JSON 스키마 제어**: LLM이 올바른 포맷의 JSON을 항상 일관되게 반환하도록 프롬프트 엔지니어링 수행.
2. **상대 시간 계산**: "내일", "다음 주 화요일", "이번 주 주말" 등 상대적인 시간 표현을 정확히 분석하기 위해 현재 날짜(Anchor Date)를 시스템 프롬프트에 동적으로 바인딩하는 기법 적용.
