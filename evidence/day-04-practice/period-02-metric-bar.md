# 2교시 연습 — Metric·Bar·Top values

- 필수 권장 시간: 40분
- 선택 도전: 5분
- 제출 상태 확인: 5분
- 시작 기준: Discover 20,000건, KQL/filter 없음
- 화면 순서: [Metric](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#5-패널-1--전체-상품-수-metric), [category Bar](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#6-패널-2--카테고리별-상품-수-bar)

## (공통·필수) 문제 1 — 전체 상품 수 Metric 제작

빈 Dashboard에 Lens Metric을 추가하세요.

- Data View: 공통 `products`
- 계산: Records 또는 Count of records
- 제목: `전체 상품 수`
- 정상 기준: 20,000

### 결과 입력

- Dashboard 이름: 수업2
- 사용한 계산: Count of records
- 실제 Metric 값: 9,818 (시간 범위 Last 1 year 기준). 전체 실제 문서 수는 10,000(`GET /products/_count`)
- 시간 범위: Last 1 year
- KQL/filter/control 상태: 없음
- 정상/보류/오류와 이유: YELLOW — 가이드 기준(20,000)과 다르다. 원인은 (1) Day2/Day4 데이터셋 버전 불일치(10,000 vs 20,000, 1교시 문제1에 기록)와 (2) 시간 범위가 전체 생성 기간을 완전히 덮지 못해 10,000 중 182건이 "Last 1 year" 밖에 있는 것 두 가지가 겹친 것이다.
- 캡처 파일: `evidence/day-04/common-dashboard.png`

## (공통·필수) 문제 2 — category Bar 제작

같은 Dashboard에 category별 상품 수 Bar를 만드세요.

- 그룹 field: `category`
- 그룹 방식: Top values
- Number of values: 8
- 값: Count of records
- 제목: `카테고리별 상품 수`

### 설정·결과 입력

- Bar 방향: vertical
- x축 또는 category 차원: `category`(Top 8 values) — 전자기기·패션·생활·도서·반려동물·뷰티·스포츠·식품
- y축 또는 Metric: Count of records
- Number of values: 8
- 표시된 category 수: 8
- 각 category 값이 공통 기준과 일치하는가: 시간 필터 없이 전체로 보면 8개 모두 정확히 1,250건씩(`GET /products/_search` terms 집계로 확인, 합계 10,000). 가이드의 "8개×2,500=20,000" 기준과는 총량이 다르지만, 8개 category가 균등 분포한다는 패턴은 동일하다.
- 캡처 파일: `evidence/day-04/common-dashboard.png`

## (변형·필수) 문제 3 — Bar 방향 한 가지만 바꿔 비교

동일한 category·Count·Top 8을 유지하고 Bar 방향만 vertical과 horizontal로 바꿔 보세요.

방향은 `Style → Appearance → Bar orientation`에서 바꿉니다. 축 label 방향과 혼동하지 않습니다.

| 비교 | vertical | horizontal |
|---|---|---|
| category 이름 가독성 | 미수행 | 미수행 |
| 값 비교 속도 | 미수행 | 미수행 |
| 잘림·겹침 | 미수행 | 미수행 |

- 최종 선택: vertical(현재 저장된 상태)
- 선택 이유: 이 비교 자체를 실제로 수행하지 않았다. 시간 제약으로 처음 만든 vertical 상태를 그대로 최종본으로 유지하기로 결정했다.
- 다른 설정을 동시에 바꾸지 않았는가: 해당 없음(미수행)

## (진단·필수) 문제 4 — 막대가 하나만 남은 상황 복구

Bar에 `스포츠` 등 하나의 category만 보인다고 가정합니다. Dashboard에서 다음을 확인하고 원래 8개 category로 복구하세요.

1. category Control 선택값
2. 상단 filter pill
3. KQL
4. 시간 범위
5. Lens의 Top values 설정

### 진단 기록

- 보이던 category: 미수행 — 이 상황을 실제로 만들지 않았다.
- 발견한 제한 조건: 해당 없음
- 제거 또는 초기화한 항목: 해당 없음
- 복구 후 막대 수: 해당 없음
- 복구 후 Metric 값: 해당 없음
- 원인이 없었다면 추가로 확인한 Lens 설정: 해당 없음
- 캡처 파일: 없음

이 진단을 수행하지 않은 이유: 공통 Dashboard에 category Control 자체를 만들지 않기로 결정했기 때문에(`evidence/day-04/dashboard-review.md` 2절), Control 선택으로 하나의 category만 남는 상황이 발생하지 않는다. filter pill·KQL로 인위적으로 좁혀보는 것도 시간상 하지 않았다.

## (개인·선택 도전) 문제 5 — 내 범주 field로 Metric+Bar 설계

자기 데이터의 전체 규모 Metric과 범주별 Bar를 설계하거나 만드세요. 범주 field가 없으면 필요한 field를 설계합니다.

- 개인 index/Data View: `shop-logs`
- 전체 규모가 의미하는 것: 지금까지 쌓인 로그 이벤트 전체 건수
- 범주 field: `log_level`
- 실제 고유값 수: 3 (`INFO`, `WARN`, `ERROR`)
- Top N 선택값과 이유: 3 — 고유값이 3개뿐이라 전부 표시
- 예상 사용자 판단: 어떤 레벨이 가장 흔한지, ERROR 비중이 급증했는지 확인
- 실제 제작 여부: 실제로 만들었다 — `전체 로그 수` Metric(1,000)과 `log_level` Donut/Bar를 개인 Dashboard에 이미 넣었다.
- 부족한 경우 필요한 field와 예시값: 해당 없음(이미 존재하는 field로 제작 완료)
- 캡처 또는 설계 문서 경로: `evidence/day-04/personal-dashboard.png`

## 교시 완료 신호

- GREEN: Metric 20,000, category Bar 8개, 제목 2개, 비교·복구 기록 완료
- YELLOW: 패널은 있으나 값·Top N·제목 중 하나가 다름
- RED: Lens 저장 또는 Dashboard 복귀 불가

**판정: YELLOW** — 필수 패널 2개(Metric, category Bar)는 실제로 만들고 저장했다. 문제3(방향 비교)과 문제4(진단)는 시간 제약과 Control 미생성 결정 때문에 실제로 수행하지 않고 그 사실을 그대로 기록했다.
