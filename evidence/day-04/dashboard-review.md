# Day 4 Dashboard 테스트·해석·개선 기록

## 1. 기본 상태

- Dashboard 제목: `내꺼` (Kibana에 저장된 이름 그대로. 나중에 `개인 PBL Dashboard - 이상혁`으로 다시 저장하면 이 줄도 고칠 것)
- Data View: `shop-logs`
- 시간 범위: Last 1 year
- 전체 문서 수: 1,000
- 패널 수: 6 (Metric, log_level Donut, log_level Bar, 레벨×예외 Treemap, http_status 2개)

## 2. filter/control 전후 테스트

| 항목 | 적용 전 | 적용 조건 | 적용 후 | Clear 후 | 정상 여부 |
|---|---:|---|---:|---:|---|
| 전체 규모 Metric | 1,000 | 미적용 | - | - | 해당 없음 |
| 비교 패널 대표값 | - | 미적용 | - | - | 해당 없음 |
| 세 번째 확인값 | - | 미적용 | - | - | 해당 없음 |

filter랑 control은 안 만들었다. 패널 수(6개)로 7교시 기준(4개 이상)은 넘겼고, 남은 시간에 control까지 붙이는 대신 지금 화면을 그대로 두기로 했다. 그래서 서비스별로 나눠 보는 건 못 한다.

## 3. 핵심값 교차 검증

| Dashboard 값 | 비교 화면/요청 | 비교값 | 일치 여부 | 다르면 확인한 원인 |
|---|---|---:|---|---|
| 전체 로그 수 Metric 1,000 | `GET /shop-logs/_count` | 1,000 | 같음 | - |
| log_level Donut INFO 71.1% | `evidence/day-02-data.md` 실측 | 711건(71.1%) | 같음 | - |
| log_level Donut ERROR 10.1% | 위와 같은 집계 | 101건(10.1%) | 같음 | - |
| Treemap ERROR 소계 11.21% | Donut의 ERROR | 10.1% | 조금 다름 | Treemap은 예외로 한 번 더 쪼갠 하위 집계라 반올림 차이일 수 있다. Inspect로는 아직 안 봤다 |

## 4. 결과 해석

조건 → 핵심값 → 비교 → 판단/다음 행동 순서로 2문장 이상 작성합니다.

1. log_level이 INFO 71.1%, WARN 18.8%, ERROR 10.1%로 나왔다. Day2에 잡은 목표(70/20/10)랑 붙어서 데이터는 쓸 만하다고 봤다.
2. ERROR 안에서 NullPointerException(6건)이 SocketTimeoutException(4건)보다 많다. 타임아웃보다 null 참조를 먼저 봐야 할 것 같다.

## 5. 말할 수 없는 것

현재 데이터에 없는 사건이나 field 때문에 단정할 수 없는 내용을 적습니다.

- 예: `products.created_at`만으로 판매 추세를 알 수 없다.
- 내 Dashboard에서 단정할 수 없는 것: control이 없어서 서비스별로 못 나눈다. 특정 서비스에 예외가 몰리는지는 이 화면만 봐서는 모른다.

## 6. 개선 전·후

- 발견한 문제: (1) Donut이랑 Bar가 같은 걸 두 번 보여준다 (2) http_status 패널 2개가 Lens 기본 제목 그대로고 내용도 겹친다 (3) control이 없다
- 개선 전 설정 또는 화면: `evidence/day-04/personal-dashboard.png`
- 수정한 내용: 없음
- 수정한 이유: 패널 수가 이미 기준(4개 이상)을 넘어서 지금 상태로 두기로 했다. 위 3개는 한계로만 적어둔다
- 개선 후 확인 결과: 해당 없음

## 7. 최종 제출 체크

- [x] 모든 패널 제목이 질문과 연결된다. (http_status 2개는 Lens 기본 라벨 그대로. 6절 참고)
- [x] 라벨·숫자·축이 겹치거나 잘리지 않는다.
- [x] 의도하지 않은 KQL·filter pill이 남아 있지 않다.
- [ ] filter/control이 관련 패널에 함께 적용된다. — 안 만들었음 (2절)
- [x] 저장 후 다시 열어도 같은 상태가 복구된다.
- [x] 전체 화면 캡처를 저장했다. (`personal-dashboard.png`)
- [x] 개인 저장소에 commit했다.
