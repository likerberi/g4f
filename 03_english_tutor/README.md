# Scenario 3: 오프라인 1:1 영어 회화 튜터 (Offline English Speaking Tutor)

## 💡 개요
비행기 모드나 지하철 등 네트워크 연결이 불가능하거나 제한된 오프라인 환경에서도, 디바이스 로컬(On-device)에서 돌아가는 Gemma 4를 통해 영어 회화 롤플레잉 및 문법 첨삭을 수행할 수 있는 회화 교육용 챗봇입니다.

---

## 🛠️ 주요 기술 스펙
- **On-device LLM (Gemma 4 IT 2B/9B)**: 대용량 언어 모델을 스마트폰 내에서 직접 추론하도록 Flutter 패키지(예: `flutter_sherpa_onnx`, `llama.cpp` dart FFI 연동) 또는 로컬 단말 내 경량 포팅 환경을 구축합니다.
- **챗 메모리 관리(Chat Memory)**: 제한된 메모리 환경(Mobile RAM)에서 세션 대화 히스토리를 효율적으로 요약하고 윈도잉(Windowing)하는 경량 메모리 버퍼 구현.
- **System Prompting & Role Playing**: 비즈니스 회화, 입국 심사, 레스토랑 주문 등 다양한 가상 상황을 제공하고 사용자의 발화를 친절하게 교정해 주는 롤플레잉 프롬프트 세팅.

---

## 🚀 아키텍처 및 데이터 흐름
```text
사용자 음성/텍스트 입력 ("I want to ordering coffee")
  ➡️ 로컬 디바이스 내 On-device Gemma 4 Engine (오프라인)
  ➡️ 실시간 교정 및 답변 생성:
     - 교정: "I want to order coffee" (order 뒤에 -ing 제거 가이드)
     - 답변: "Sure! What kind of coffee would you like?"
  ➡️ Flutter UI 대화형 버블 업데이트 및 TTS(Text-to-Speech) 오디오 재생
```

---

## 📅 로드맵 및 도전 과제
1. **모바일 하드웨어 최적화**: 모바일 CPU/GPU 가속을 위해 모델을 `GGUF` 또는 `INT4/INT8` 단위로 극도로 양자화(Quantization)하여 메모리 소모와 발열을 최소화.
2. **문법 교정 엔진**: 단순 답변 생성을 넘어 사용자가 사용한 틀린 영문장만 별도의 하이라이트 카드로 추출하여 보여주는 복합 UI 바인딩.
