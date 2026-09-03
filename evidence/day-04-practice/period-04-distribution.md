# 4교시 연습 — 가격 분포·재고 비율·등록 시점

- 필수 권장 시간: 42분
- 선택 도전: 3분
- 제출 상태 확인: 5분
- 시작 기준: 공통 Dashboard 3패널 저장 완료
- 화면 순서: [가격 구간](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#8-패널-4--가격-구간별-상품-수-bar), [Pie→Donut](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#9-패널-5--재고-상태-비율-donut), [Line](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#10-패널-6--월별-상품-등록-분포-line)

## (공통·필수) 문제 1 — 50,000원 단위 가격 분포

`price`와 Count of records를 사용해 가격대별 Bar를 만드세요. 자동 막대 수를 맞추려고 `Decrease granularity`를 반복하지 말고 `Create custom ranges`를 사용합니다.

### 결과 입력

- 실제 입력한 구간: 0 이상 50,000 미만 / 50,000 이상 100,000 미만 / 100,000 이상 150,000 미만 / 150,000 이상 200,000 미만 / 200,000 이상 (권장 예시 그대로 사용)
- 구간 사이 빈틈·중복 확인 방법: `GET /products/_search`의 `range` aggregation으로 5개 구간의 합이 전체 문서 수와 같은지 확인 → 3,621+2,289+1,359+1,264+1,467 = 10,000으로 정확히 일치, 빈틈·중복 없음
- 가장 많은 가격 구간: 0 이상 50,000 미만
- 해당 구간 실제 문서 수: 3,621
- 제목: 가격 구간별 상품 수
- 캡처 파일: `evidence/day-04/common-dashboard.png`

## (공통·필수) 문제 2 — 재고 상태 Donut과 기준값 검증

차트 유형 `Pie`에서 `in_stock` Top values와 Count of records를 설정한 뒤, `Style → Appearance → Donut hole → Medium`으로 Donut을 만드세요.

### 결과 입력

- true 실제 값: 8,469건 (약 85%, 화면 표시와 일치)
- false 실제 값: 1,531건 (약 15%, 화면 표시와 일치)
- 합계: 10,000
- 전체 20,000과 일치하는가: 아니다. 실제 총 문서 수가 10,000이라 20,000과는 애초에 맞지 않는다(1교시 문제1에서 확인한 데이터셋 버전 불일치). true/false 비율(85%/15%)은 화면 표시와 정확히 일치한다.
- 비율 또는 값 표시 방식: 퍼센트(%)
- 제목: (화면 캡처에서 별도 패널 제목 텍스트가 뚜렷이 보이지 않음 — 재확인 필요)
- 한 조각만 보일 때 먼저 확인할 조건: KQL, filter pill, 시간 범위, Lens의 in_stock Top values 설정(Number of values가 1로 줄어 있지 않은지)
- 캡처 파일: `evidence/day-04/common-dashboard.png`

## (공통·필수) 문제 3 — 월별 상품 등록 Line과 잘못된 해석 수정

`created_at` Date histogram과 Count of records를 사용하고 `Minimum interval`에 `1M`을 입력해 월 단위 Line을 만드세요.

다음 문장을 데이터에 맞게 수정하세요.

> 월별 판매량이 증가하거나 감소하는 모습을 보여 준다.

### 결과 입력

- 선택한 interval: 1M(월)
- 보이는 월 구간: 2025-08 ~ 2026-08 (13개월, `GET /products/_search` date_histogram으로 확인. 2025-08은 131건뿐인 부분월)
- 실제 패널 제목: 월별 상품 등록 분포(화면 캡처의 왼쪽 상단 라벨 기준)
- 수정한 설명 문장: "월별 **상품 등록 건수**가 800건대를 중심으로 다소 오르내리는 모습을 보여준다. 이것이 판매량이나 매출 증감을 의미하지는 않는다."
- `created_at`의 실제 의미: 상품이 시스템에 등록(생성)된 시점. 판매·주문·매출 시점이 아니다.
- 판매 추이를 알려면 추가로 필요한 사건/field: 주문·결제 이벤트를 나타내는 별도 index/필드(예: `order_id`, `ordered_at`, `sold_price`)가 필요하다. 현재 `products`에는 없다.
- 캡처 파일: `evidence/day-04/common-dashboard.png`

## (개인·필수) 문제 4 — 분포·비율·시간 중 하나 선택

자기 질문에 필요한 유형 하나만 선택해 설계하거나 만드세요.

- 선택 유형: 비율
- 사용자 질문: 로그 레벨(INFO/WARN/ERROR) 구성 비율은 어떤가
- field와 mapping type: `log_level`(keyword)
- 그룹/구간/시간 단위: Top values(3개, 전수)
- 차트: Donut(Pie + Donut hole)
- 완료 기준: INFO/WARN/ERROR 비율의 합이 100%
- 실제 결과 또는 부족한 데이터: 실제로 만들었다 — INFO 71.1%(711건), WARN 18.8%(188건), ERROR 10.1%(101건). Day2 데이터 생성 목표 비율(70/20/10)과 근접해 대표성이 있다고 판단했다.
- 해석 시 주의할 한계: 이 비율만으로는 어떤 서비스(`service_name`)에서 발생했는지는 알 수 없다. Control/Filter가 없기 때문이다.

## (선택 도전) 문제 5 — 가격 구간 대안 비교

미수행(선택 문제) — 시간 제약으로 시도하지 않았다.

## 교시 완료 신호

- GREEN: price Bar, stock Donut, created_at Line, 개인 유형 선택 완료
- YELLOW: 세 패널은 있으나 구간·값·시간 의미 중 하나가 다름
- RED: 숫자/상태/날짜 field를 Lens에 설정할 수 없음

**판정: GREEN(개인 유형 포함), 단 총량 기준은 YELLOW** — price/Donut/Line 세 패널의 구간 설계와 계산 방식은 정상이고 실측값으로 검증했다. 다만 전체 총량이 가이드 기준(20,000)과 다르다는 점은 1교시부터 이어지는 동일한 버전 불일치다.
