# 8교시 연습 — 사용 시나리오·교차 검증·개선·제출

- 필수 권장 시간: 45분
- 선택 도전: 필수 제출 완료 후
- 함께 작성: `../day-04/dashboard-review.md`
- 시작 기준: 개인 Dashboard 4패널 이상과 상호작용 1개 저장 완료
- 화면 순서: [Inspect·결과 저장·백업](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#15-결과-저장공유백업)

## (개인·필수) 문제 1 — 사용자 행동 두 가지 테스트

Dashboard 사용자가 실제로 할 행동 두 가지를 실행하세요. 각 행동은 조건 적용과 결과 확인, 원상 복구를 포함합니다.

| 행동 | 시작 상태 | 적용 조건 | 변한 패널·값 | 사용자의 판단 | 복구 방법 | 복구 성공 |
|---|---|---|---|---|---|---|
| 1 | 미수행 | 미수행 | 미수행 | 미수행 | 미수행 | 미수행 |
| 2 | 미수행 | 미수행 | 미수행 | 미수행 | 미수행 | 미수행 |

- 두 행동이 서로 다른 이유: 해당 없음
- 사용자가 멈추거나 헷갈린 지점: 해당 없음
- 캡처 파일: 없음

미수행. Control/Filter가 없어 "조건 적용→복구"를 시연할 상호작용 자체가 없음(`evidence/day-04/dashboard-review.md`, `period-07-personal-build.md` 문제4).

## (개인·필수) 문제 2 — 핵심값 3개 교차 검증

Dashboard의 핵심값 3개를 Discover, `_count`, 또는 aggregation 요청과 비교하세요. `Inspect`는 Dashboard 편집 모드에서 해당 패널의 `Panel menu`에 있습니다. 권한이나 화면 상태로 보이지 않으면 Discover 또는 제공 요청 파일로 검증합니다.

| Dashboard 패널·값 | 동일하게 맞춘 시간·조건 | 비교 방법 | 비교값 | 일치 여부 | 다르면 확인한 원인 |
|---|---|---|---:|---|---|
| 1. 전체 로그 수 Metric: 1,000 | 조건 없음(전체) | `GET /shop-logs/_count` | 1,000 | 일치 | - |
| 2. log_level Donut INFO: 71.1% | 조건 없음(전체) | `GET /shop-logs/_search` terms aggregation | 711건(71.1%) | 일치 | - |
| 3. Treemap ERROR 소계: 11.21% | 조건 없음(전체) | 동일 aggregation의 ERROR terms 합 | 10.1%(101건) | 근소 불일치 | Treemap이 exception_class로 한 번 더 나눈 하위 집계라 반올림 차이로 추정. 정확한 원인 미확인(Kibana Inspect 필요) |

- 비교에 사용한 요청 파일 또는 Discover 캡처: `requests.http`의 `V1-T22-P` 구간
- 세 값을 신뢰할 수 있는 이유: 화면 값이 아니라 Elasticsearch API 응답과 직접 대조. 3개 중 2개 정확히 일치

## (개인·필수) 문제 3 — 문제 하나를 실제로 수정하고 재검증

제목, field, 집계, 정렬, 구간, 시간, filter, layout 중 한 문제를 골라 수정하세요. 문제가 없다고 생각되면 사용성 문제 하나를 개선합니다.

개인 Dashboard의 문제(Donut/Bar 중복, http_status 패널 2개 중복)는 고치지 않고 한계로만 기록(`period-07-personal-build.md` 문제4, `dashboard-review.md` 6절). 아래는 공통 Dashboard에서 실제로 고친 사례.

- 발견한 문제: 공통 Dashboard의 전체 상품 수 Metric이 20,000도 아니고 10,000도 아닌 1로 표시됨
- 문제 유형: 시간(시간 범위)
- 수정 전 설정 또는 결과: 시간 범위가 `Aug 22, 2026 @ 12:36 ~ 14:35`(2시간)로 좁게 설정, Metric = 1
- 추정 원인: 실제 `products` 데이터의 `created_at` 분포(2025-08~2026-08)와 겹치지 않는 좁은 절대 시간 범위
- 수정한 한 가지: 시간 범위를 `Last 1 year`로 변경
- 수정 후 결과: Metric = 9,818
- 같은 조건 재검증 결과: `GET /products/_count` 실제값 10,000과 182건 차이. `Last 1 year`도 전체 생성 기간을 다 덮지는 못함
- 개선/보류/악화 판정과 근거: 개선. 1 → 9,818, 남은 차이 182건도 시간 범위 문제
- 수정 전·후 캡처: 수정 전 없음, 수정 후 `evidence/day-04/common-dashboard.png`

## (개인·필수) 문제 4 — 결과 3·한계 2·필요 데이터 1과 제출

### 결과 3개

1. 조건·핵심값·비교·판단: 전체 조건에서 `log_level` INFO 71.1% / WARN 18.8% / ERROR 10.1%. 목표 70/20/10에 실측 71.1/18.8/10.1. 합성 데이터임.
2. 조건·핵심값·비교·판단: ERROR 101건 중 `NullPointerException` 6건(5.9%), `SocketTimeoutException` 4건(4.0%). null 참조 예외가 우선 조치 후보. 표본 101건으로 적음.
3. 조건·핵심값·비교·판단: `http_status`에서 5xx(500+504=216건, 21.6%)가 4xx(404=49건, 4.9%)보다 많다. 서버 오류부터 봐야 할 것 같다.

### 현재 데이터의 한계 2개

1. Control/Filter가 없어 `service_name`별로 예외나 상태코드를 나눠 볼 수 없다.
2. ERROR 101건 중 `exception_class`가 `IllegalStateException`/`SocketTimeoutException`/`NullPointerException` 중 하나로 채워진 문서는 12건, 나머지 89건은 비어 있다. 이 89건의 실패 원인은 알 수 없다.

### 추가로 필요한 데이터 1개

- field: 위 89건의 실제 `exception_class` 값(또는 `error_message` 같은 원인 설명 field)
- mapping type: keyword
- 예시값: `TimeoutException`, `IllegalArgumentException`, `ConnectionResetException` 등 현재 3종 외의 예외 클래스
- 값 분포·생성 규칙: ERROR 101건 전체가 예외 클래스를 갖도록 생성 규칙 보완 필요
- 추가되면 답할 수 있는 질문: ERROR 로그 전체의 실패 원인 유형별 비율(현재는 12/101건만 파악 가능)

### 제출 기록

- Dashboard 제목: 내꺼(공통은 `수업2`)
- 전체 화면 캡처 경로: `evidence/day-04/personal-dashboard.png`, `evidence/day-04/common-dashboard.png`
- JSON export 경로(선택): 없음(미생성)
- `dashboard-plan.md` 경로: `evidence/day-04/dashboard-plan.md`
- `dashboard-review.md` 경로: `evidence/day-04/dashboard-review.md`
- 개인 저장소 commit SHA: 이 커밋 직후 `git log -1`로 확인
- 미완료 또는 알려진 제한 사항: (1) 공통과 개인 Dashboard 모두 Control/Filter 없음 (2) 개인 Dashboard의 Donut/Bar 중복, http_status 패널 2개 중복 미정리 (3) Dashboard 저장명이 권장 규칙(`D4 공통 상품 Dashboard - 이상혁`, `D4 개인 미션 - 주제 - 이상혁`)과 다름(각각 `수업2`, `내꺼`) (4) 공통 데이터 총량이 가이드 기준 20,000이 아닌 실제 배포치 10,000 (5) 5교시 문제2와 3, 7교시 문제4, 8교시 문제1 등 Control/Filter 관련 문항 다수 미수행

PDF 메뉴가 없으면 정상입니다. 현재 수업 환경의 `More → Export`는 Dashboard JSON을 제공하며, 관련 객체까지 옮길 때는 `Stack Management → Kibana → Saved Objects → Export`를 사용합니다. 화면 캡처를 기본 근거로 제출합니다.

## (선택 도전) 문제 5 — 다른 사람이 재현할 수 있는지 점검

자신의 기록만 보고 다음 항목을 다시 수행해 보거나 옆 학생에게 문서만 보여 줍니다.

- [ ] 올바른 Data View를 선택할 수 있다.
- [ ] 시간 범위를 동일하게 맞출 수 있다.
- [ ] Control/Filter 조건을 재현할 수 있다.
- [ ] 핵심값 3개의 비교 근거를 찾을 수 있다.
- [ ] Dashboard를 초기 상태로 복구할 수 있다.

- 재현에 부족했던 설명: 미수행
- 추가한 설명: 미수행
- 최종 재현 판정: 미수행

## Day 4 최종 완료 신호

- GREEN: 필수 32문제의 요구 산출물, 개인 Dashboard, plan/review, 캡처, commit 완료
- YELLOW: Dashboard는 있으나 검증·개선·commit 중 하나가 미완료
- RED: 저장된 Dashboard 또는 제출 근거가 없음

**판정: YELLOW**. Dashboard 2개, `dashboard-plan.md`, `dashboard-review.md`, 캡처, commit 모두 존재. Control/Filter 문항 다수 미수행, 총 문서 수 기준값이 가이드와 다름.
