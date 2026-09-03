# Dashboard 계획

## 1. Dashboard 사용자와 목적

- Dashboard를 볼 사용자: 백엔드 운영 담당자
- 이 사용자가 확인하려는 상황: 서비스별 ERROR 발생량, 시간대별로 늘어나는 구간
- Dashboard를 본 뒤 할 다음 행동: ERROR가 몰린 서비스랑 시간대를 찾아서 그 구간 로그를 자세히 본다

## 2. 분석 질문

Dashboard에 넣기 전에 먼저 aggregation 또는 ES|QL로 확인할 질문을 적습니다.

1. 서비스별 ERROR 건수는 각각 몇 건인가?
2. 시간대별 ERROR 발생 추이는 어떻게 되는가?

## 3. 차트 계획

Day 4 수업 완료 기준은 Lens 차트 4개입니다. 각 차트는 하나의 질문에 답해야 합니다.

| 번호 | Lens 시각화 | 답할 질문 | 사용할 field | 집계 또는 표시 방식 | 결과를 본 뒤의 판단·행동 |
|---:|---|---|---|---|---|
| 1 | Metric | 전체 ERROR는 몇 건인가? | `log_level` | Records Count | 평소보다 많은지 본다 |
| 2 | Bar 또는 Table | 어느 서비스에 ERROR가 몰리는가? | `service_name` | Top values | 점검할 서비스를 고른다 |
| 3 | Bar 또는 Table | 어떤 예외가 자주 나는가? | `exception_class` | Top values | 반복되는 예외부터 고친다 |
| 4 | Histogram 또는 Line | 언제 ERROR가 늘었는가? | `timestamp` | date histogram | 장애 난 구간을 찾는다 |

> 평가 최소 기준은 차트 2개 이상이지만, 수업에서는 차트 4개를 완성합니다.

## 4. Control과 시간 설정

- Options list 또는 range control에 사용할 field: `service_name`, `log_level`
- 이 control로 함께 좁힐 차트: 차트 1~4 전부
- Data View 이름: `shop-logs`(개인), `쇼핑몰 상품 데이터`(공통 products)
- 시간 field: 사용
- 시간 field를 사용한다면 field 이름과 기간: `timestamp`, 최근 14일

## 5. 제목과 배치 계획

- Dashboard 제목: 쇼핑몰 백엔드 로그 장애 현황
- 상단에 둘 차트 또는 control: 서비스·레벨 control과 차트 1
- 가운데에 둘 차트: 차트 2, 차트 3
- 하단에 둘 차트: 차트 4

## 6. Day 4 완료 기록

- 실제로 만든 차트 수: 개인 6개(Metric, log_level Donut, log_level Bar, 레벨×예외 Treemap, http_status 2개), 공통 6개
- Dashboard 화면 캡처: `evidence/day-04/personal-dashboard.png`(개인), `evidence/day-04/common-dashboard.png`(공통)
- 선택 export: 안 만들었다
- 계획과 다르게 바꾼 점 및 이유:
  - 차트 1을 "전체 ERROR 수" 대신 "전체 로그 수"로 만들었다. ERROR 비중은 옆에 있는 레벨 Donut에서 바로 보인다
  - 차트 2, 4(서비스별 ERROR, 시간대별 추이) 대신 레벨 비율 Donut, 레벨×예외 Treemap, http_status를 만들었다. 어떤 예외부터 고칠지가 더 급해 보여서 바꿨다
  - control은 계획했는데 시간이 모자라서 안 만들었다. 그래서 서비스별로 나눠 보는 건 못 한다
  - 캡처 경로가 `evidence/dashboard.png`가 아니라 `evidence/day-04/` 아래다. Day 4 배포본이 정한 파일명을 따랐다
