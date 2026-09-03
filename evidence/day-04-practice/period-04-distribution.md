# 4교시 연습 — 가격 분포·재고 비율·등록 시점

- 필수 권장 시간: 42분
- 선택 도전: 3분
- 제출 상태 확인: 5분
- 시작 기준: 공통 Dashboard 3패널 저장 완료
- 화면 순서: [가격 구간](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#8-패널-4--가격-구간별-상품-수-bar), [Pie→Donut](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#9-패널-5--재고-상태-비율-donut), [Line](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#10-패널-6--월별-상품-등록-분포-line)

## (공통·필수) 문제 1 — 50,000원 단위 가격 분포

`price`와 Count of records를 사용해 가격대별 Bar를 만드세요. 자동 막대 수를 맞추려고 `Decrease granularity`를 반복하지 말고 `Create custom ranges`를 사용합니다.

권장 구간 예:

- 0 이상 50,000 미만
- 50,000 이상 100,000 미만
- 100,000 이상 150,000 미만
- 150,000 이상 200,000 미만
- 200,000 이상

### 결과 입력

- 실제 입력한 구간: 권장 예시 그대로 5개
- 구간 사이 빈틈·중복 확인 방법: `GET /products/_search`의 `range` aggregation으로 구간 합 대조 → 3,621+2,289+1,359+1,264+1,467 = 10,000, 빈틈이나 중복 없음
- 가장 많은 가격 구간: 0 이상 50,000 미만
- 해당 구간 실제 문서 수: 3,621
- 제목: 가격 구간별 상품 수
- 캡처 파일: `evidence/day-04/common-dashboard.png`

## (공통·필수) 문제 2 — 재고 상태 Donut과 기준값 검증

차트 유형 `Pie`에서 `in_stock` Top values와 Count of records를 설정한 뒤, `Style → Appearance → Donut hole → Medium`으로 Donut을 만드세요. 차트 목록에서 Donut을 찾지 않습니다.

### 결과 입력

- true 실제 값: 8,469건 (약 85%, 화면 표시와 동일)
- false 실제 값: 1,531건 (약 15%, 화면 표시와 동일)
- 합계: 10,000
- 전체 20,000과 일치하는가: 아니다. 총 문서 수가 10,000(데이터셋 버전 차이). 비율 85%/15%는 화면과 동일
- 비율 또는 값 표시 방식: 퍼센트(%)
- 제목: 캡처에서 판독 불가(재확인 필요)
- 한 조각만 보일 때 먼저 확인할 조건: KQL, filter pill, 시간 범위, Lens의 in_stock Top values(Number of values)
- 캡처 파일: `evidence/day-04/common-dashboard.png`

## (공통·필수) 문제 3 — 월별 상품 등록 Line과 잘못된 해석 수정

`created_at` Date histogram과 Count of records를 사용하고 `Minimum interval`에 `1M`을 입력해 월 단위 Line을 만드세요.

다음 문장을 데이터에 맞게 수정하세요.

> 월별 판매량이 증가하거나 감소하는 모습을 보여 준다.

### 결과 입력

- 선택한 interval: 1M(월)
- 보이는 월 구간: 2025-08 ~ 2026-08 (13개월, 2025-08은 131건 부분월)
- 실제 패널 제목: 월별 상품 등록 분포
- 수정한 설명 문장: "월별 **상품 등록 건수**가 800건대에서 오르내린다. 판매량이나 매출 증감이 아니다."
- `created_at`의 실제 의미: 상품이 시스템에 등록된 시점. 판매나 주문 시점이 아님
- 판매 추이를 알려면 추가로 필요한 사건/field: 주문/결제 이벤트 index와 `order_id`, `ordered_at`, `sold_price`. `products`에는 없음
- 캡처 파일: `evidence/day-04/common-dashboard.png`

## (개인·필수) 문제 4 — 분포·비율·시간 중 하나 선택

자기 질문에 필요한 유형 하나만 선택해 설계하거나 만드세요.

| 선택 | 필요한 데이터 | 적합한 질문 예 |
|---|---|---|
| 분포 | 숫자 field | 값이 어느 구간에 몰려 있는가? |
| 비율 | 상태·범주 field | 상태별 구성은 어떠한가? |
| 시간 | 날짜 field | 기간별 문서 수는 어떻게 달라지는가? |

- 선택 유형: 비율
- 사용자 질문: 로그 레벨(INFO/WARN/ERROR) 구성 비율은 어떤가
- field와 mapping type: `log_level`(keyword)
- 그룹/구간/시간 단위: Top values(3개, 전수)
- 차트: Donut(Pie + Donut hole)
- 완료 기준: INFO/WARN/ERROR 비율의 합이 100%
- 실제 결과 또는 부족한 데이터: 제작 완료. INFO 71.1%(711건), WARN 18.8%(188건), ERROR 10.1%(101건). 목표 70/20/10에 실측 71.1/18.8/10.1
- 해석 시 주의할 한계: 어떤 서비스(`service_name`)에서 났는지는 알 수 없음(Control/Filter 없음)

## (선택 도전) 문제 5 — 가격 구간 대안 비교

50,000원 구간과 자신이 설계한 다른 구간을 비교하세요. field와 Count는 유지합니다.

| 비교 | 50,000원 단위 | 대안 구간 |
|---|---|---|
| 막대 수 | 미수행 | 미수행 |
| 읽기 쉬움 | 미수행 | 미수행 |
| 판단에 유용함 | 미수행 | 미수행 |

- 최종 선택과 이유: 미수행

## 교시 완료 신호

- GREEN: price Bar, stock Donut, created_at Line, 개인 유형 선택 완료
- YELLOW: 세 패널은 있으나 구간·값·시간 의미 중 하나가 다름
- RED: 숫자/상태/날짜 field를 Lens에 설정할 수 없음

**판정: GREEN(개인 유형 포함), 단 총량 기준은 YELLOW**. price/Donut/Line 세 패널의 구간 설계와 계산 정상. 총량만 가이드 기준(20,000)과 다름.
