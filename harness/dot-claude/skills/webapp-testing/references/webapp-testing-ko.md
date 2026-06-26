# webapp-testing — 분리 레퍼런스 (harness-diet 2026-06-06)

> SKILL.md 본문에서 분리된 상세. 원본은 archive/harness-diet-2026-06-06/file-backups 참조.

## 참조

- 전문가 역할: `~/.claude/skills/_core/roles.md`
- 문제 해결 프로토콜: `~/.claude/skills/_core/protocols.md`


## Playwright API 핵심 레퍼런스

### 페이지 탐색

```python
page.goto('http://localhost:3000')
page.goto('http://localhost:3000', wait_until='networkidle')
page.reload()
page.go_back()
page.go_forward()
```

### 요소 선택

```python
# 역할 기반 (권장)
page.get_by_role('button', name='Submit')
page.get_by_role('textbox', name='Email')
page.get_by_role('link', name='Home')

# 텍스트 기반
page.get_by_text('Welcome')
page.get_by_label('Password')
page.get_by_placeholder('Enter email')

# CSS/XPath
page.locator('css=.btn-primary')
page.locator('xpath=//div[@class="card"]')

# 테스트 ID
page.get_by_test_id('submit-button')
```

### 인터랙션

```python
# 클릭
page.get_by_role('button', name='Submit').click()
page.get_by_role('button', name='Submit').dblclick()

# 입력
page.get_by_role('textbox', name='Email').fill('test@example.com')
page.get_by_role('textbox', name='Search').type('query', delay=100)

# 선택
page.get_by_role('combobox').select_option('option1')
page.get_by_role('checkbox').check()

# 파일 업로드
page.get_by_label('Upload').set_input_files('file.pdf')

# 키보드
page.keyboard.press('Enter')
page.keyboard.press('Control+A')
```

### 대기 전략

```python
# 로드 상태
page.wait_for_load_state('networkidle')
page.wait_for_load_state('domcontentloaded')

# 요소 대기
page.wait_for_selector('.result', state='visible')
page.wait_for_selector('.spinner', state='hidden')

# 시간 대기 (최후 수단)
page.wait_for_timeout(1000)

# 커스텀 조건
page.wait_for_function('document.readyState === "complete"')
```

### 스크린샷 및 디버깅

```python
# 전체 페이지
page.screenshot(path='screenshot.png', full_page=True)

# 특정 요소
page.locator('.card').screenshot(path='card.png')

# 콘솔 로그 수집
page.on('console', lambda msg: print(f'[{msg.type}] {msg.text}'))

# 네트워크 모니터링
page.on('request', lambda req: print(f'>> {req.method} {req.url}'))
page.on('response', lambda res: print(f'<< {res.status} {res.url}'))
```

## 테스트 패턴

### 폼 제출 테스트

```python
def test_form_submission(page):
    page.goto('http://localhost:3000/contact')
    page.wait_for_load_state('networkidle')

    page.get_by_label('Name').fill('Test User')
    page.get_by_label('Email').fill('test@test.com')
    page.get_by_label('Message').fill('Hello')
    page.get_by_role('button', name='Send').click()

    page.wait_for_selector('.success-message', state='visible')
    assert page.get_by_text('Message sent').is_visible()
```

### 인증 플로우 테스트

```python
def test_login_flow(page):
    page.goto('http://localhost:3000/login')
    page.wait_for_load_state('networkidle')

    page.get_by_label('Email').fill('user@test.com')
    page.get_by_label('Password').fill('password123')
    page.get_by_role('button', name='Login').click()

    page.wait_for_url('**/dashboard')
    assert 'dashboard' in page.url
```

### 반응형 테스트

```python
def test_mobile_menu(page):
    page.set_viewport_size({'width': 375, 'height': 812})
    page.goto('http://localhost:3000')
    page.wait_for_load_state('networkidle')

    # 모바일 메뉴 토글
    page.get_by_role('button', name='Menu').click()
    assert page.get_by_role('navigation').is_visible()
```

## 디버깅 전략

### 문제 진단 순서

1. **스크린샷 촬영**: 현재 페이지 상태 확인
2. **콘솔 로그 확인**: JavaScript 에러 탐지
3. **네트워크 요청 확인**: API 호출 상태 검증
4. **DOM 검사**: 요소 존재 여부 확인
5. **대기 전략 조정**: 타이밍 이슈 해결

### 일반적 실패 원인

| 증상 | 원인 | 해결 |
|------|------|------|
| Element not found | 동적 렌더링 미완료 | wait_for_selector 추가 |
| Timeout | 네트워크 지연 | timeout 증가, networkidle 사용 |
| Stale element | DOM 재렌더링 | 로케이터 재취득 |
| Click intercepted | 오버레이 요소 | force=True 또는 오버레이 닫기 |

## 서버 관리 팁

### with_server.py 고급 옵션

```bash
# 헬스체크 URL 지정
python scripts/with_server.py \
  --server "npm run dev" --port 3000 \
  --health-check /api/health \
  -- python test.py

# 타임아웃 설정
python scripts/with_server.py \
  --server "npm run dev" --port 3000 \
  --timeout 60 \
  -- python test.py
```


## 고급 테스트 패턴

### 네트워크 모킹

```python
def test_with_mocked_api(page):
    # API 응답 모킹
    page.route('**/api/users', lambda route: route.fulfill(
        status=200,
        content_type='application/json',
        body='[{"id": 1, "name": "Test User"}]'
    ))

    page.goto('http://localhost:3000/users')
    page.wait_for_load_state('networkidle')
    assert page.get_by_text('Test User').is_visible()
```

### 멀티탭 테스트

```python
def test_multi_tab(context):
    page1 = context.new_page()
    page2 = context.new_page()

    page1.goto('http://localhost:3000/chat')
    page2.goto('http://localhost:3000/chat')

    # 첫 번째 탭에서 메시지 전송
    page1.get_by_role('textbox').fill('Hello')
    page1.get_by_role('button', name='Send').click()

    # 두 번째 탭에서 수신 확인
    page2.wait_for_selector('text=Hello')
    assert page2.get_by_text('Hello').is_visible()
```

### 파일 다운로드 테스트

```python
def test_file_download(page):
    with page.expect_download() as download_info:
        page.get_by_role('link', name='Download Report').click()

    download = download_info.value
    assert download.suggested_filename == 'report.pdf'

    path = download.path()
    assert os.path.getsize(path) > 0
```

### 접근성 자동 테스트

```python
def test_accessibility(page):
    page.goto('http://localhost:3000')
    page.wait_for_load_state('networkidle')

    # axe-core 주입 및 실행
    page.evaluate('''
        const script = document.createElement('script')
        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/axe-core/4.7.0/axe.min.js'
        document.head.appendChild(script)
    ''')
    page.wait_for_function('typeof axe !== "undefined"')

    results = page.evaluate('axe.run()')
    violations = results['violations']
    assert len(violations) == 0, f"Accessibility violations: {violations}"
```

### 시각적 회귀 테스트

```python
def test_visual_regression(page):
    page.goto('http://localhost:3000')
    page.wait_for_load_state('networkidle')

    # 기준 스크린샷 생성 (첫 실행)
    page.screenshot(path='screenshots/baseline.png', full_page=True)

    # 변경 후 비교 스크린샷
    page.screenshot(path='screenshots/current.png', full_page=True)

    # 이미지 비교는 별도 라이브러리로 수행
```

## 성능 테스트

```python
def test_page_performance(page):
    page.goto('http://localhost:3000')
    page.wait_for_load_state('networkidle')

    metrics = page.evaluate('''() => {
        const perf = performance.getEntriesByType('navigation')[0]
        return {
            domContentLoaded: perf.domContentLoadedEventEnd,
            loadComplete: perf.loadEventEnd,
            firstPaint: performance.getEntriesByType('paint')
                .find(p => p.name === 'first-contentful-paint')?.startTime
        }
    }''')

    assert metrics['domContentLoaded'] < 3000
    assert metrics['firstPaint'] < 2000
```

## 환경별 설정

| 환경 | headless | slow_mo | 용도 |
|------|:--------:|:-------:|------|
| CI | True | 0 | 자동화 테스트 |
| 개발 | False | 500 | 디버깅 |
| 녹화 | False | 200 | 데모 영상 |


## 네트워크 모킹

```javascript
// API 응답 모킹
await page.route('**/api/users', async route => {
  await route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify([{ id: 1, name: 'Test User' }])
  });
});

// 네트워크 에러 시뮬레이션
await page.route('**/api/data', route => route.abort('connectionrefused'));

// 지연 시뮬레이션
await page.route('**/api/slow', async route => {
  await new Promise(resolve => setTimeout(resolve, 3000));
  await route.continue();
});
```

## 멀티탭 테스트

```javascript
// 새 탭 열기
const [newPage] = await Promise.all([
  context.waitForEvent('page'),
  page.click('a[target="_blank"]')
]);
await newPage.waitForLoadState();
console.log(await newPage.title());
```

## 파일 다운로드 테스트

```javascript
// 다운로드 이벤트 대기
const [download] = await Promise.all([
  page.waitForEvent('download'),
  page.click('#download-btn')
]);
const path = await download.path();
console.log('Downloaded to: ' + path);
```

## 접근성 테스트

```javascript
// axe-core 기반 접근성 검사
const { AxeBuilder } = require('@axe-core/playwright');

const results = await new AxeBuilder({ page })
  .withTags(['wcag2a', 'wcag2aa'])
  .analyze();

console.log('Violations: ' + results.violations.length);
results.violations.forEach(v => {
  console.log('- ' + v.id + ': ' + v.description + ' (' + v.impact + ')');
});
```

## 시각적 회귀 테스트

```javascript
// 스크린샷 비교
await expect(page).toHaveScreenshot('homepage.png', {
  maxDiffPixels: 100,
  threshold: 0.2
});

// 특정 요소 스크린샷
const header = page.locator('header');
await expect(header).toHaveScreenshot('header.png');
```

## 성능 테스트

```javascript
// 페이지 로딩 성능 측정
const metrics = await page.evaluate(() => {
  const timing = performance.getEntriesByType('navigation')[0];
  return {
    domContentLoaded: timing.domContentLoadedEventEnd,
    loadComplete: timing.loadEventEnd,
    firstPaint: performance.getEntriesByType('paint')
      .find(e => e.name === 'first-paint')?.startTime
  };
});
console.log('Performance:', metrics);
```

## 인증 상태 관리

```javascript
// 인증 상태 저장
await page.context().storageState({ path: 'auth.json' });

// 인증 상태 로드
const context = await browser.newContext({
  storageState: 'auth.json'
});
```

## 모바일 테스트

```javascript
// 모바일 뷰포트 설정
const context = await browser.newContext({
  viewport: { width: 375, height: 812 },
  isMobile: true,
  hasTouch: true
});

// 터치 제스처
await page.touchscreen.tap(200, 300);
```

## 테스트 구조화 모범 사례

### Page Object 패턴

```javascript
class LoginPage {
  constructor(page) {
    this.page = page;
    this.emailInput = page.locator('#email');
    this.passwordInput = page.locator('#password');
    this.submitButton = page.locator('button[type="submit"]');
  }

  async login(email, password) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }

  async getErrorMessage() {
    return this.page.locator('.error-message').textContent();
  }
}
```

### 테스트 격리

- 각 테스트는 독립적으로 실행 가능해야 함
- beforeEach에서 상태 초기화
- 테스트 간 데이터 공유 금지
- 고유한 테스트 데이터 생성 (타임스탬프 활용)


## 테스트 디버깅 전략

### 실패 테스트 분석

테스트 실패 시 체계적으로 원인을 분석하는 방법:

1. 에러 메시지 확인: 타임아웃인지, 요소 미발견인지, 단언 실패인지 구분
2. 스크린샷 분석: 실패 시점의 페이지 상태 확인
3. 네트워크 로그 확인: API 응답이 예상과 다른지 확인
4. 콘솔 에러 확인: JavaScript 런타임 에러 여부

### 불안정한 테스트(Flaky Test) 해결

불안정한 테스트의 주요 원인과 해결 방법:

| 원인 | 증상 | 해결 방법 |
|------|------|----------|
| 타이밍 이슈 | 간헐적 타임아웃 | waitForSelector 대신 waitForLoadState 사용 |
| 데이터 의존성 | 순서에 따라 실패 | 테스트별 독립 데이터 생성 |
| 애니메이션 | 요소 위치 불안정 | animation: none 강제 적용 |
| 외부 API | 네트워크 지연 | API 모킹으로 격리 |

### Playwright 트레이스 활용

```javascript
// 트레이스 기록 활성화
const context = await browser.newContext();
await context.tracing.start({ screenshots: true, snapshots: true });

// 테스트 실행 후 트레이스 저장
await context.tracing.stop({ path: 'trace.zip' });
// npx playwright show-trace trace.zip 으로 분석
```

## CI/CD 환경 테스트

### GitHub Actions 설정

```yaml
name: E2E Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
```

### 병렬 실행 최적화

- workers 수 설정: CPU 코어 수에 맞춰 조정
- 샤딩: 대규모 테스트를 여러 CI 인스턴스에 분배
- retries 설정: 불안정한 테스트에 대한 재시도 횟수 지정

