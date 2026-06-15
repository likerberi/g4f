import 'package:flutter/material.dart';

class WritingStyle {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String promptInstruction;
  final List<Map<String, String>> fewShotExamples;

  const WritingStyle({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.promptInstruction,
    required this.fewShotExamples,
  });
}

final List<WritingStyle> defaultStyles = [
  WritingStyle(
    id: 'business',
    name: '비즈니스 격식체',
    description: '보고서, 기획서, 업무 메일에 어울리는 간결하고 전문적인 스타일',
    icon: Icons.business_center_rounded,
    promptInstruction: 'Convert the input text into a formal, concise, and professional business report/email style in Korean. Use polite formal endings (~음/임, ~드립니다, ~합니다). Avoid emotional exclamation marks, slang, or emojis. Focus on clarity, logical structure, and objective vocabulary.',
    fewShotExamples: [
      {
        'input': '오늘 회의 끝남 대박 피곤함 보고서 써야되는데 귀찮',
        'output': '금일 회의 일정을 종료하였습니다. 금일 중 완료 예정인 보고서 작성을 조속히 진행토록 하겠습니다.',
      },
      {
        'input': '진짜 대박 아이디어 생각남 이거 하면 우리 1등 할 수 있을 듯 언넝 해보자',
        'output': '당사의 경쟁력을 확보하고 시장 우위를 선점하기 위한 신규 사업 계획(안)을 제안합니다. 신속히 검토 절차에 착수할 것을 건의드립니다.',
      }
    ],
  ),
  WritingStyle(
    id: 'instagram',
    name: '인스타 감성피드',
    description: '해시태그와 이모티콘을 곁들인 트렌디하고 감성적인 SNS 스타일',
    icon: Icons.camera_alt_rounded,
    promptInstruction: 'Convert the input text into a trendy, emotional, and engaging Instagram post style in Korean. Use casual and friendly language, add relevant emojis throughout the text, and append 3-5 popular, context-aware hashtags at the end. Make it feel warm, visually pleasing, and social.',
    fewShotExamples: [
      {
        'input': '오늘 퇴근길에 하늘 보니까 이뻐서 기분 좋았어',
        'output': '오늘 퇴근길, 유난히 붉게 물든 하늘을 마주했어요 🌅 바쁜 하루 끝에 이런 선물 같은 풍경을 만날 수 있음에 감사한 저녁 ✨ 여러분도 오늘 하루 수고 많으셨어요 🤍\n\n#퇴근길 #오늘의하늘 #노을맛집 #소소한행복 #하루끝',
      },
      {
        'input': '친구랑 카페에서 수다떪 케이크 맛있었다',
        'output': '달콤한 딸기 생크림 케이크 한 입에 행복 가득 🍓🍰 오랜만에 친구와 쉴 새 없이 쏟아낸 이야기보따리, 시간 가는 줄도 몰랐네 ☕️ 매일이 오늘만 같았으면 🧸\n\n#카페투어 #디저트카페 #우정스타그램 #수다타임 #행복한주말',
      }
    ],
  ),
  WritingStyle(
    id: 'legal',
    name: '엄격한 법률체',
    description: '합리적 주장과 객관적 논거가 담긴 계약서/소장 양식의 톤',
    icon: Icons.gavel_rounded,
    promptInstruction: 'Convert the input text into a strict, formal legal statement or contract terminology in Korean. Use passive legal phrases, define parties clearly (e.g., 본인, 상대방), and state facts with objective legal logic. Use words like ~에 관하여, ~하고자 합니다, ~에 해당함, ~의 책임으로 함.',
    fewShotExamples: [
      {
        'input': '얘가 돈 빌려가놓고 안 갚음 전화도 안 받아 진짜 어이없네',
        'output': '본인은 상대방에게 금전을 대여하였으나 상대방은 약정 기일 내에 변제 의무를 이행하지 아니하였으며, 통신 연락을 전면 회피하고 있습니다. 이에 따라 채무 불이행 사실을 고지하며 조속한 이행을 강력히 촉구하는 바입니다.',
      },
      {
        'input': '저 물건 샀는데 고장나 있었어요 환불해주세요',
        'output': '매수인(본인)이 매도인(상대방)으로부터 구매한 물품에 중대한 하자(작동 불능)가 발견된바, 민법상 하자담보책임에 기하여 매매 계약의 해제 및 즉각적인 대금 반환 청구권을 행사하고자 합니다.',
      }
    ],
  ),
  WritingStyle(
    id: 'email',
    name: '따뜻한 안부메일',
    description: '배려와 감사, 다정한 정서가 깃든 편지 형태의 서간체 스타일',
    icon: Icons.email_rounded,
    promptInstruction: 'Convert the input text into a warm, polite, and caring letter/email style in Korean. Focus on expressing gratitude, wishing the recipient good health and happiness, and maintaining a gentle and respectful tone (~ 드림, ~ 드립니다). Include a warm opening and closing remark.',
    fewShotExamples: [
      {
        'input': '나 내일 휴가라 연락 안 됨 급한 건 팀장님한테 물어봐',
        'output': '안녕하세요. 늘 아낌없는 성원을 보내주셔서 깊이 감사드립니다. 다름이 아니라, 제가 내일 연차 휴가 예정으로 이메일 및 전화 확인이 다소 지연될 수 있음을 미리 양해 구하고자 합니다. 긴급히 확인이 필요하신 사항은 당사 팀장님께 연락 주시면 조속히 도움받으실 수 있습니다. 건강하고 행복한 하루 보내시길 바랍니다. 감사합니다. [작성자] 드림',
      },
      {
        'input': '도와줘서 고마워 밥 한번 살게',
        'output': '보내주신 따뜻한 성원과 아낌없는 도움 덕분에 염려하던 일을 성공적으로 마칠 수 있었습니다. 깊은 감사의 말씀을 전하며, 조만간 따뜻한 식사 자리를 마련하여 보답의 뜻을 전하고자 합니다. 늘 건강하시고 좋은 일만 가득하시길 진심으로 기원합니다. 감사합니다.',
      }
    ],
  ),
  WritingStyle(
    id: 'humor',
    name: '재치있는 유머체',
    description: '위트와 적절한 드립을 믹스하여 흥미를 끄는 유쾌한 대화 스타일',
    icon: Icons.sentiment_very_satisfied_rounded,
    promptInstruction: 'Convert the input text into a witty, humorous, slightly sarcastic but highly entertaining style in Korean. Use slang naturally if appropriate for humor, funny expressions, and lighthearted exaggeration to make it funny and engaging. Keep it lively and cheerful.',
    fewShotExamples: [
      {
        'input': '오늘 회사 가기 싫어서 이불 속에 누워있음',
        'output': '중요 발표: 금일부로 저의 이불과의 혼인 서약식 및 24시간 풀타임 포옹 세션이 개최되어 출근이 심각하게 지연되는 불가항력적 사태가 발생하였습니다. 이불 밖은 위험하니까요... 😂',
      },
      {
        'input': '다이어트 한다고 해놓고 떡볶이 시킴',
        'output': '인생 최대의 모순 봉착. 뇌는 "닭가슴살 샐러드"를 말했으나, 저의 신성한 손가락은 이미 "엽기떡볶이 맵기 3단계에 중국당면 추가" 결제를 마쳤습니다. 떡볶이는 탄수화물이 아니라 사랑이자 단백질 흡수를 위한 추진력이라 믿어 의심치 않습니다 🐷',
      }
    ],
  ),
];
