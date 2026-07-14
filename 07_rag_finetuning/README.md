# 🧠 시나리오 7: RAG & FineTuning 통합 지식 어시스턴트

## 📋 개요

**RAG (Retrieval-Augmented Generation) & FineTuning 통합 지식 어시스턴트**는 사용자의 개인 문서와 도메인 특화 지식을 바탕으로 정확하고 맥락에 맞는 답변을 제공하는 차세대 AI 어시스턴트입니다.

이 시나리오는 두 가지 핵심 기술을 결합합니다:
1. **RAG (검색 증강 생성)**: 벡터 데이터베이스에서 관련 문서를 실시간으로 검색하여 LLM의 답변에 반영
2. **FineTuning (파인튜닝)**: 도메인 특화 데이터셋으로 모델을 미세 조정하여 전문성 향상

---

## 🎯 주요 기능

### 1. 문서 임베딩 & 벡터 검색
- 사용자가 업로드한 PDF, TXT, Markdown 문서를 자동으로 청크 단위로 분할
- 온디바이스 임베딩 모델(sentence-transformers)을 활용한 벡터화
- 로컬 벡터 데이터베이스(Chroma/FAISS)에 저장 및 시맨틱 검색

### 2. RAG 기반 질의응답
- 사용자 질문에 대해 벡터 데이터베이스에서 Top-K 관련 문서 검색
- 검색된 컨텍스트와 함께 Gemma 4에 전달하여 정확한 답변 생성
- 출처(Source Citation) 자동 표시로 신뢰성 확보

### 3. FineTuning 워크플로우
- 도메인 특화 Q&A 데이터셋 준비 인터페이스
- LoRA(Low-Rank Adaptation) 기반 효율적인 파인튜닝
- 파인튜닝 전후 성능 비교 대시보드

### 4. 하이브리드 모드
- **Pure RAG 모드**: 기본 Gemma 4 + 검색 문서
- **FineTuned 모드**: 파인튜닝된 모델 단독 사용
- **RAG + FineTuned 모드**: 두 기술을 결합한 최고 성능 모드

---

## 🏗️ 기술 스택

### Flutter & Dart
- **flutter_markdown**: 답변 및 문서 렌더링
- **file_picker**: 로컬 문서 업로드
- **sqflite**: 문서 메타데이터 관리

### AI & ML
- **Gemma 4 (2B/9B)**: 기본 언어 모델
- **sentence-transformers**: 임베딩 생성
- **Ollama**: 로컬 LLM 추론 엔진
- **LoRA**: 파라미터 효율적 파인튜닝

### 벡터 데이터베이스
- **ChromaDB**: 온디바이스 벡터 스토어
- **FAISS**: 고속 유사도 검색 엔진

### 백엔드 (선택사항)
- **FastAPI**: 파인튜닝 파이프라인 서버
- **Hugging Face Transformers**: 모델 훈련 및 관리

---

## 📱 주요 화면 구성

1. **홈 화면**: 문서 업로드 및 질의응답 인터페이스
2. **문서 관리**: 업로드된 문서 목록, 삭제, 재임베딩
3. **RAG 설정**: Top-K 값, 청크 사이즈, 임베딩 모델 선택
4. **FineTuning 스튜디오**: 데이터셋 준비, 훈련 시작, 진행률 모니터링
5. **성능 비교**: 파인튜닝 전후 답변 품질 A/B 테스트

---

## 🚀 시작하기 (Quick Start)

### 사전 요구사항
- Flutter SDK 3.16.0 이상
- Python 3.10+ (파인튜닝 기능 사용 시)
- Ollama 설치 (로컬 추론 사용 시)

### 설치 및 실행
```bash
# 1. 디렉토리 이동
cd 07_rag_finetuning

# 2. 의존성 설치
flutter pub get

# 3. (선택) Python 백엔드 설정
cd backend
pip install -r requirements.txt
uvicorn main:app --reload

# 4. Flutter 앱 실행
flutter run
```

---

## 🎓 학습 포인트

이 시나리오를 통해 다음을 배울 수 있습니다:

1. **RAG 파이프라인 구축**: 문서 청킹, 임베딩, 벡터 검색, 프롬프트 인젝션
2. **FineTuning 실무**: LoRA/QLoRA를 활용한 효율적인 모델 커스터마이징
3. **하이브리드 AI 아키텍처**: 검색 기반 + 훈련 기반 접근법의 시너지
4. **온디바이스 ML**: 모바일 환경에서의 벡터 연산 최적화
5. **프롬프트 엔지니어링**: 컨텍스트 윈도우 관리 및 답변 품질 향상

---

## 📊 사용 예시

### 의료 도메인 어시스턴트
사용자가 의학 교과서, 논문을 업로드한 후:
- **질문**: "당뇨병 환자의 식이요법 가이드라인은?"
- **RAG 답변**: [문서 3, p.42-45]에서 검색된 내용 기반 답변 + 출처 표시
- **FineTuned 모델**: 의학 도메인 Q&A로 훈련된 모델의 전문적 답변

### 법률 자문 봇
법령, 판례를 임베딩하고 파인튜닝하여:
- 정확한 법조문 인용과 함께 법률 질의에 답변
- 계약서 조항 검토 및 리스크 분석

---

## 🔮 향후 확장 계획

- [ ] 멀티모달 RAG: 이미지, 표, 차트 포함 문서 처리
- [ ] 그래프 RAG: 지식 그래프 기반 추론
- [ ] 지속적 학습: 사용자 피드백 기반 온라인 파인튜닝
- [ ] 다국어 지원: 한국어, 영어, 일본어 등 멀티링구얼 벡터 검색

---

## 📚 참고 자료

- [LangChain Documentation](https://python.langchain.com/)
- [Hugging Face LoRA Guide](https://huggingface.co/docs/peft/conceptual_guides/lora)
- [ChromaDB Documentation](https://docs.trychroma.com/)
- [Gemma Fine-tuning Guide](https://ai.google.dev/gemma/docs/lora_tuning)

---

**Status**: 🚧 개발 예정 (Planned)
