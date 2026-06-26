# 다이어그램 생성 규칙 (STAGE 3 상세)

## HTML/SVG 다이어그램 표준

모든 다이어그램은 standalone HTML 파일로 생성한다. 외부 CDN 의존 없음.

### 기본 템플릿 구조
```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{프로젝트명} — {다이어그램 제목}</title>
<style>
body { margin:0; padding:20px; background:#0d1117; font-family:-apple-system,sans-serif; display:flex; justify-content:center }
svg { max-width:700px; width:100% }
text { font-family:-apple-system,'Pretendard',sans-serif }
</style>
</head>
<body>
<svg width="100%" viewBox="0 0 680 {높이}">
<defs>
  <marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
    <path d="M2 1L8 5L2 9" fill="none" stroke="#888" stroke-width="1.5" stroke-linecap="round"/>
  </marker>
</defs>
{SVG 콘텐츠}
</svg>
</body>
</html>
```

### 컬러 팔레트 (다크 테마)
| 용도 | 배경(fill) | 테두리(stroke) | 제목 텍스트 | 부제 텍스트 |
|------|----------|-------------|----------|----------|
| 기본/구조 | #2d333b | #888 | #ccc | #888 |
| 인증/API | #0c2244 | #378add | #b5d4f4 | #85b7eb |
| 데이터/성공 | #0d3b2e | #1d9e75 | #9fe1cb | #5dcaa5 |
| AI/핵심 | #1e1e3a | #7f77dd | #cecbf6 | #afa9ec |
| 경고/비동기 | #2a1e08 | #ef9f27 | #fac775 | #ef9f27 |
| 위험/에러 | #2a1a0e | #d85a30 | #f5c4b3 | #f0997b |
| 저장/영구 | #0c2e12 | #639922 | #c0dd97 | #97c459 |
| 핑크/합성 | #2e1528 | #d4537e | #f4c0d1 | #ed93b1 |

### 노드 표준
- 단일 라인: height=44, rx=8
- 이중 라인(제목+부제): height=56, rx=8
- 강조 노드: stroke-width=1 (기본 0.5)
- 컨테이너: rx=12~14, stroke-width=1

### 필수 다이어그램 목록
1. **시스템 아키텍처**: 클라이언트 → API Gateway → 서비스들 → DB/캐시/스토리지
2. **데이터 흐름**: 핵심 기능의 데이터가 어떻게 흘러가는지
3. **프로젝트 특화**: AI 파이프라인, 결제 플로우, 실시간 통신 등

### 규칙
- viewBox 너비는 항상 680
- 노드 간 최소 간격 60px
- 화살표가 다른 노드를 관통하지 않도록 L자 경로 사용
- 각 노드에 정량적 라벨(지연시간, 비용 등) 가능하면 표시
- 분기(병렬 처리)는 좌우로 나누고 다시 합류
