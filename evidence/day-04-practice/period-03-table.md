# 3교시 연습 — Table·Count·Average·정렬

- 필수 권장 시간: 40분
- 선택 도전: 5분
- 제출 상태 확인: 5분
- 시작 기준: 공통 Dashboard의 Metric과 category Bar 저장 완료
- 화면 순서: [Table 상세 가이드](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#7-패널-3--브랜드별-상품-수와-평균-가격-table)

## (공통·필수) 문제 1 — brand Table 제작

다음 세 열을 가진 Table을 만드세요.

1. `brand` Top values
2. Count of records
3. Average of `price`

Average는 `Metrics → Quick function → Average → Field: price`로 추가합니다. 열 Name은 `브랜드`, `상품 수`, `평균 가격`으로 지정합니다.

패널 제목은 `브랜드별 상품 수와 평균 가격`으로 저장합니다.

### 설정·결과 입력

- brand Number of values: 10
- 첫 번째 Metric과 label: `brand` Top values → 브랜드
- 두 번째 Metric과 label: Average of `price` → 평균 가격 (정렬 기준으로 사용, 아래 참고)
- 표시된 행 수: 10
- 첫 3개 브랜드와 상품 수: NeoTech(243건), MobiCore(271건), PixelWorks(226건)
- 첫 3개 브랜드의 평균 가격: NeoTech 232,803.70원, MobiCore 231,226.20원, PixelWorks 228,904.87원
- 캡처 파일: `evidence/day-04/common-dashboard.png`

캡처의 브랜드 순서(NeoTech → MobiCore → PixelWorks → Auralis → SoundLab → CleanMate → LumiHome → SimpleDay → DailyForm → HomeNest)는 **평균 가격 내림차순**. Count 열이 함께 표시됐는지는 캡처로 확인 안 됨.

## (변형·필수) 문제 2 — 정렬 기준 하나만 바꿔 비교

Table의 나머지 설정을 유지하고 다음 두 정렬을 비교하세요.

- 설정 A: 상품 수 내림차순
- 설정 B: 평균 가격 내림차순

| 비교 | 설정 A | 설정 B |
|---|---|---|
| 첫 번째 브랜드 | 한끼연구소 | NeoTech |
| 첫 번째 상품 수 | 277건 | 243건 |
| 첫 번째 평균 가격 | 38,869.31원 | 232,803.70원 |

- 순서가 달라진 이유: 상품 수가 많은 브랜드(한끼연구소)와 평균 가격이 높은 브랜드(NeoTech)가 다름
- “상품이 많은 브랜드”에 맞는 정렬: 설정 A(상품 수 내림차순)
- “평균 가격이 높은 브랜드”에 맞는 정렬: 설정 B(평균 가격 내림차순)
- 최종 Dashboard에서 선택한 정렬과 이유: 설정 B(평균 가격 내림차순). 제목상 평균 가격이 더 눈에 띄는 값이라서

## (진단·필수) 문제 3 — 평균만 보고 결론 내리는 오류 찾기

평균 가격이 높은 브랜드 하나를 선택하세요. 그 브랜드의 상품 수를 함께 확인하고 다음 질문에 답하세요.

- 선택한 브랜드: NeoTech
- 평균 가격: 232,803.70원 (평균 가격 1위)
- 상품 수: 243건 (상품 수 1위 한끼연구소 277건보다 적음)
- 평균 가격만 보면 내릴 수 있는 결론: "NeoTech가 가장 잘 팔리는 브랜드"라는 오해
- 상품 수를 함께 보면 추가로 필요한 주의: 평균 가격이 높다고 판매량이 많은 건 아님
- 현재 데이터로 말할 수 없는 것: "가장 중요한 브랜드". `products`에 판매/주문 field 없음
- Count와 Average를 함께 보여 줘야 하는 이유: 평균만 보면 몇 건짜리 평균인지 몰라서

## (개인·필수) 문제 4 — 내 데이터의 정확한 값 비교 Table

자기 데이터에서 범주 field 하나와 숫자 field 하나를 선택해 Table을 설계하거나 만드세요.

- 사용자: 백엔드 운영·장애 대응 담당자
- 분석 질문: 서비스별로 요청이 얼마나 오래 걸리는가
- 행에 사용할 범주 field: `service_name`
- Metric 1과 이유: Count of records. 서비스별 로그 발생량
- Metric 2와 이유: Average of `duration_ms`. 서비스별 평균 응답시간
- Top N: 4 (`service_name` 고유값 4개)
- 정렬 기준: Average `duration_ms` 내림차순(느린 서비스 우선)
- 완료 기준: 4개 서비스 전부 표시, 평균 응답시간 순 정렬
- 실제 결과 또는 데이터 부족 상태: 설계만. 실제 제작 안 함
- 캡처/설계 문서 경로: 이 문서(캡처 없음)

## (선택 도전) 문제 5 — Table에 필요한 Metric 하나 추가

`rating` 또는 `review_count`처럼 실제 mapping에 있는 숫자 field 중 하나를 선택해 세 번째 Metric을 추가하고, 판단에 도움이 되는지 평가하세요.

- 추가한 field와 계산: 미수행
- 추가 전 질문: 미수행
- 추가 후 알 수 있는 것: 미수행
- 표가 너무 복잡해졌는가: 미수행
- 유지/제거 결정과 이유: 미수행

## 교시 완료 신호

- GREEN: 3열 Table, 정렬 비교, 평균 해석, 개인 Table 설계 완료
- YELLOW: Table은 있으나 Average·정렬·label 중 하나가 미완료
- RED: Table에 brand 행 또는 price 평균을 표시할 수 없음

**판정: YELLOW**. Table, 정렬 비교, 평균 해석 완료. 문제4는 설계만, 문제5는 미수행.
