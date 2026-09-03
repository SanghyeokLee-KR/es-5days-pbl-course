# 8교시 연습 — 사용 시나리오·교차 검증·개선·제출

- 필수 권장 시간: 45분
- 선택 도전: 필수 제출 완료 후
- 함께 작성: `../day-04/dashboard-review.md`
- 시작 기준: 개인 Dashboard 4패널 이상과 상호작용 1개 저장 완료
- 화면 순서: [Inspect·결과 저장·백업](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#15-결과-저장공유백업)

## (개인·필수) 문제 1 — 사용자 행동 두 가지 테스트

| 행동 | 시작 상태 | 적용 조건 | 변한 패널·값 | 사용자의 판단 | 복구 방법 | 복구 성공 |
|---|---|---|---|---|---|---|
| 1 | 미수행 | 미수행 | 미수행 | 미수행 | 미수행 | 미수행 |
| 2 | 미수행 | 미수행 | 미수행 | 미수행 | 미수행 | 미수행 |

- 두 행동이 서로 다른 이유: 해당 없음
- 사용자가 멈추거나 헷갈린 지점: 해당 없음
- 캡처 파일: 없음

미수행 사유: 개인 Dashboard에 Control/Filter를 만들지 않기로 결정했기 때문에(`evidence/day-04/dashboard-review.md`, `period-07-personal-build.md` 문제4) "조건 적용→복구"를 실제로 시연할 상호작용이 없다. 예상값을 지어내지 않고 미수행으로 남긴다.

## (개인·필수) 문제 2 — 핵심값 3개 교차 검증

| Dashboard 패널·값 | 동일하게 맞춘 시간·조건 | 비교 방법 | 비교값 | 일치 여부 | 다르면 확인한 원인 |
|---|---|---|---:|---|---|
| 1. 전체 로그 수 Metric: 1,000 | 조건 없음(전체) | `GET /shop-logs/_count` | 1,000 | 일치 | - |
| 2. log_level Donut INFO: 71.1% | 조건 없음(전체) | `GET /shop-logs/_search` terms aggregation | 711건(71.1%) | 일치 | - |
| 3. Treemap ERROR 소계: 11.21% | 조건 없음(전체) | 동일 aggregation의 ERROR terms 합 | 10.1%(101건) | 근소 불일치 | Treemap이 exception_class로 한 번 더 나눈 하위 집계라 반올림·표시 방식 차이로 추정 — 정확한 원인은 Kibana Inspect로 추가 확인 필요(미확인) |

- 비교에 사용한 요청 파일 또는 Discover 캡처: `requests.http`의 `V1-T*` 구간, 이번 세션에서 실행한 `GET /shop-logs/_search` aggregation(터미널 결과 기준, 별도 캡처 없음)
- 세 값을 신뢰할 수 있는 이유: 세 값 모두 Kibana 화면에 표시된 값이 아니라 Elasticsearch API 응답을 직접 조회해 대조했고, 그중 2개는 정확히 일치했다.

## (개인·필수) 문제 3 — 문제 하나를 실제로 수정하고 재검증

개인 Dashboard 자체에서는 발견한 문제(도넛/Bar 중복, http_status 패널 2개 중복)를 실제로 고치지 않고 한계로만 기록하기로 결정했다(`period-07-personal-build.md` 문제4, `dashboard-review.md` 6절). 대신 이번 세션에서 실제로 겪고 수정한 문제는 공통 Dashboard 쪽에서 발생했으므로 그 사례를 기록한다.

- 발견한 문제: 공통 Dashboard의 전체 상품 수 Metric이 20,000도 아니고 10,000도 아닌 1로 표시됨
- 문제 유형: 시간(시간 범위)
- 수정 전 설정 또는 결과: 시간 범위가 `Aug 22, 2026 @ 12:36 ~ 14:35`(2시간)로 좁게 설정, Metric = 1
- 추정 원인: 실제 `products` 데이터의 `created_at` 분포(2025-08~2026-08)와 겹치지 않는 좁은 절대 시간 범위
- 수정한 한 가지: 시간 범위를 `Last 1 year`로 변경
- 수정 후 결과: Metric = 9,818
- 같은 조건 재검증 결과: `GET /products/_count`의 전체 실제값 10,000과 비교하면 182건 차이 — "Last 1 year"도 전체 생성 기간을 완전히 덮지는 못한다(2025-08의 일부가 여전히 범위 밖일 수 있음).
- 개선/보류/악화 판정과 근거: 개선. 1→9,818로 정상 범위에 근접했고, 남은 차이(9,818 vs 10,000)의 원인도 시간 범위 문제로 명확히 설명된다.
- 수정 전·후 캡처: 수정 전 별도 캡처 없음(대화 중 확인), 수정 후 `evidence/day-04/common-dashboard.png`

## (개인·필수) 문제 4 — 결과 3·한계 2·필요 데이터 1과 제출

### 결과 3개

1. 전체 조건에서 `log_level` 비율은 INFO 71.1% / WARN 18.8% / ERROR 10.1%로 확인됐고, Day2 데이터 생성 목표(70/20/10)와 비교해 근접했다. 따라서 이 데이터가 대표성을 갖는다고 판단한다. 다만 실제 운영 트래픽이 아니라 합성 데이터라는 한계는 있다.
2. ERROR 중 `NullPointerException`(6건)이 `SocketTimeoutException`(4건)보다 많다고 확인됐고 전체 ERROR(101건) 대비 각각 5.9%·4.0%다. 따라서 null 참조 예외를 우선 조치 후보로 검토한다. 다만 표본이 101건으로 적어 비율 차이가 안정적인지는 단정하지 않는다.
3. `http_status`에서 5xx(500+504=216건, 21.6%)가 4xx(404=49건, 4.9%)보다 많다고 확인됐다. 따라서 클라이언트 오류보다 서버 내부 오류 대응을 우선 검토한다. 다만 상태 코드만으로 실제 장애의 사용자 영향 범위는 단정하지 않는다.

### 현재 데이터의 한계 2개

1. Control/Filter가 없어 서비스(`service_name`)별로 예외·상태코드를 나눠 볼 수 없다. 특정 서비스에 문제가 집중되는지 이 Dashboard만으로는 판단할 수 없다.
2. ERROR 101건 중 `exception_class`가 `IllegalStateException`/`SocketTimeoutException`/`NullPointerException` 중 하나로 채워진 문서는 12건뿐이고 나머지 89건은 이 field가 비어 있다(실측 확인). 이 89건의 실패 원인 유형은 현재 Treemap·Table로는 알 수 없다.

### 추가로 필요한 데이터 1개

- field: 위 89건의 실제 `exception_class` 값(또는 `error_message` 같은 원인 설명 field)
- mapping type: keyword
- 예시값: `TimeoutException`, `IllegalArgumentException`, `ConnectionResetException` 등 현재 3종 외의 실제 예외 클래스
- 값 분포·생성 규칙: ERROR 101건 전체가 예외 클래스를 갖도록 데이터 생성 규칙 보완 필요(현재는 일부 ERROR 문서가 예외 클래스 없이 생성됨)
- 추가되면 답할 수 있는 질문: ERROR 로그 전체의 실패 원인 유형별 비율(현재는 12/101건만 파악 가능)

### 제출 기록

- Dashboard 제목: 내꺼(공통은 `수업2`)
- 전체 화면 캡처 경로: `evidence/day-04/personal-dashboard.png`, `evidence/day-04/common-dashboard.png`
- JSON export 경로(선택): 없음(미생성)
- `dashboard-plan.md` 경로: `evidence/day-04/dashboard-plan.md`
- `dashboard-review.md` 경로: `evidence/day-04/dashboard-review.md`
- 개인 저장소 commit SHA: `247e342`(캡처·plan·review) — 이 교시별 문제지(`evidence/day-04-practice/`)는 별도 커밋으로 추가 예정
- 미완료 또는 알려진 제한 사항: (1) 공통·개인 Dashboard 모두 Control/Filter 없음 (2) 개인 Dashboard의 Donut/Bar 중복, http_status 패널 2개 중복 미정리 (3) Dashboard 저장명이 가이드 권장 규칙(`D4 공통 상품 Dashboard - 이상혁`, `D4 개인 미션 - 주제 - 이상혁`)과 다름(각각 `수업2`, `내꺼`) (4) 공통 데이터 총량이 가이드 기준 20,000이 아니라 실제 배포치 10,000 (5) 5교시 문제2·3, 7교시 문제4, 8교시 문제1 등 Control/Filter 관련 문항 다수 미수행

## (선택 도전) 문제 5 — 다른 사람이 재현할 수 있는지 점검

미수행(선택 문제) — 문서를 검토해줄 동료 학생이 없어 시도하지 않았다.

## Day 4 최종 완료 신호

- GREEN: 필수 32문제의 요구 산출물, 개인 Dashboard, plan/review, 캡처, commit 완료
- YELLOW: Dashboard는 있으나 검증·개선·commit 중 하나가 미완료
- RED: 저장된 Dashboard 또는 제출 근거가 없음

**판정: YELLOW** — Dashboard 2개(공통·개인), `dashboard-plan.md`, `dashboard-review.md`, 캡처, commit까지 전부 존재한다. 다만 Control/Filter 상호작용 관련 문항 다수가 의도적 미수행이고, 총 문서 수 기준값이 가이드와 다르다는 점이 YELLOW 판정의 근거다.
