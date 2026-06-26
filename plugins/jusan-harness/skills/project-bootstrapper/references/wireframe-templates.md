# 와이어프레임 생성 규칙 (STAGE 4 상세)

## 모바일 퍼스트 폰 프레임

모든 와이어프레임은 모바일 크기(340px)의 폰 프레임 안에 렌더링한다.

### 폰 프레임 CSS 표준
```css
.phone {
  background: #161b22;
  border-radius: 24px;
  border: 1px solid #30363d;
  width: 340px;
  overflow: hidden;
}
.phone .bar {
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #888;
  border-bottom: 1px solid #21262d;
}
.phone .body {
  padding: 16px 18px 24px;
  min-height: 540px;
}
```

### 인터랙티브 요소

**스테퍼 (다단계 화면)**:
- 상단에 점(dot) 네비게이션
- 이전/다음 버튼
- JavaScript로 단계 전환

```javascript
let currentStep = 0;
function goStep(n) {
  currentStep = n;
  document.querySelectorAll('.step').forEach((s, i) => 
    s.classList.toggle('on', i === n)
  );
  document.querySelectorAll('.dot').forEach((d, i) => 
    d.classList.toggle('on', i === n)
  );
}
```

**슬라이더 필터**:
- `<input type="range">` + 실시간 값 표시
- 변경 시 결과 카운트 업데이트

**탭 전환**:
- 클릭으로 뷰 전환 (홈 ↔ 상세 등)

### 필수 화면 목록 (프로젝트별 적응)

1. **유저 저니 전체 플로우** (SVG 다이어그램)
2. **온보딩/회원가입** (소셜 로그인)
3. **프로필/설정 등록** (핵심 데이터 입력)
4. **홈/메인 피드** (추천 + 카테고리)
5. **핵심 기능 화면** (프로젝트의 메인 기능 — 피팅, 검색, 대시보드 등)
6. **상세 화면** (상품, 콘텐츠, 프로필 등)
7. **액션 완료** (결제, 예약, 제출 등)
8. **에러 화면** (최소 5종)

### 에러 화면 규칙
- 모든 에러에 해결 방법 포함
- 기술 용어 금지
- 대안 경로 최소 2개 제공
- 톤: 다정하지만 간결

### 와이어프레임 스펙 문서 (mvp-wireframe-spec.md)
각 화면마다:
- 담당 에이전트
- UI 요소 목록
- 전환 목표 (%)
- 에러 시나리오
- Phase 2 백로그
