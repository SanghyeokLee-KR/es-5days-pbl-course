# Day 4 Dashboard 테스트·해석·개선 기록

## 1. 기본 상태

- Dashboard 제목: `내꺼` (Kibana에 저장된 실제 이름. `개인 PBL Dashboard - 이상혁`으로 다시 저장했다면 이 줄을 갱신할 것)
- Data View: `shop-logs`
- 시간 범위: Last 1 year
- 전체 문서 수: 1,000
- 패널 수: 6 (전체 로그 수 Metric, log_level Donut, log_level Bar, log_level×exception_class Treemap, http_status Top 100, http_status Top 9)

## 2. filter/control 전후 테스트

| 항목 | 적용 전 | 적용 조건 | 적용 후 | Clear 후 | 정상 여부 |
|---|---:|---|---:|---:|---|
| 전체 규모 Metric | 1,000 | 미적용 | - | - | 해당 없음 |
| 비교 패널 대표값 | - | 미적용 | - | - | 해당 없음 |
| 세 번째 확인값 | - | 미적용 | - | - | 해당 없음 |

filter/control은 만들지 않기로 결정했다. 패널 수(6개)로 7교시 필수 기준(4개 이상)은 이미 충족했고, 시간 제약상 control 추가보다 현재 화면을 최종본으로 확정하는 쪽을 선택했다. 이 결정으로 서비스(`service_name`)별로 나눠서 보는 것은 이 Dashboard에서 확인할 수 없다(5절 참고).

## 3. 핵심값 교차 검증

| Dashboard 값 | 비교 화면/요청 | 비교값 | 일치 여부 | 다르면 확인한 원인 |
|---|---|---:|---|---|
| 전체 로그 수 Metric: 1,000 | `GET /shop-logs/_count` | 1,000 | 일치 | - |
| log_level Donut INFO: 71.1% | Day2 실측 집계(`evidence/day-02-data.md` 3절) | 711건(71.1%) | 일치 | - |
| log_level Donut ERROR: 10.1% | Day2 실측 집계 | 101건(10.1%) | 일치 | - |
| Treemap ERROR 소계: 11.21% | log_level Donut ERROR | 10.1% | 근소 불일치 | Treemap이 exception_class로 한 번 더 나눈 하위 집계라 반올림·집계 방식 차이일 가능성 — 정확한 원인은 Kibana Inspect로 추가 확인 필요(미확인) |

## 4. 결과 해석

1. `log_level` 분포는 INFO 71.1% / WARN 18.8% / ERROR 10.1%로, Day2 데이터 생성 시 설정한 목표 비율(70/20/10)과 근접해 실측치가 대표성을 가진다고 판단한다.
2. Treemap에서 ERROR 중 NullPointerException(5.61%)이 SocketTimeoutException(3.74%)보다 많아, 시간 초과보다 null 참조 예외가 더 빈번한 실패 원인임을 확인했다 — 트러블슈팅 우선순위를 정하는 근거로 쓸 수 있다.

## 5. 말할 수 없는 것

- 예: `products.created_at`만으로 판매 추세를 알 수 없다.
- 내 Dashboard에서 단정할 수 없는 것: filter/control이 없어 서비스(`service_name`)별로 나눠보지 못하므로, 특정 서비스에 예외가 집중되는지는 이 화면만으로 판단할 수 없다.

## 6. 개선 전·후

- 발견한 문제: (1) log_level Donut과 Bar가 같은 질문(레벨 비율)을 두 번 보여준다. (2) `http_status` 패널 2개(Top 100 / Top 9)가 Lens 기본 제목 그대로이고 내용이 거의 겹친다. (3) filter/control이 없다.
- 개선 전 설정 또는 화면: `evidence/day-04/personal-dashboard.png` (현재 상태)
- 수정한 내용: 없음
- 수정한 이유: 패널 수(6개)가 요구 기준(4개 이상)을 이미 넘었다고 판단해 현재 화면을 최종본으로 유지하기로 결정했다. 위 3가지는 알려진 한계로만 기록한다.
- 개선 후 확인 결과: 해당 없음(미개선, 현재 상태로 확정)

## 7. 최종 제출 체크

- [x] 모든 패널 제목이 질문과 연결된다. (`http_status` 2개 패널은 Lens 기본 라벨 그대로 — 6절 한계로 기록)
- [x] 라벨·숫자·축이 겹치거나 잘리지 않는다.
- [x] 의도하지 않은 KQL·filter pill이 남아 있지 않다.
- [ ] filter/control이 관련 패널에 함께 적용된다. — 미적용(2절 참고)
- [x] 저장 후 다시 열어도 같은 상태가 복구된다.
- [x] 전체 화면 캡처를 저장했다. (`personal-dashboard.png`)
- [x] 개인 저장소에 commit했다.
