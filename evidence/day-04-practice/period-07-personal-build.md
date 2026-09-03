# 7교시 연습 — 개인 목적형 Dashboard 제작

- 필수 권장 시간: 43분
- 선택 도전: 2분
- 제출 상태 확인: 5분
- 시작 기준: `dashboard-plan.md`의 질문 4개와 A/B/C 경로 확정
- 화면 순서: [Save as](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#142-개인본-만들기), [선택 확장 패널](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#16-선택-확장-패널)

## (개인·필수) 문제 1 — 공통 원본을 보존하고 개인본 만들기

- 공통 원본 이름: 수업2
- 개인본 이름 `D4 개인 미션 - 주제 - 이름`: 내꺼(가이드 권장 이름 규칙으로 아직 다시 저장하지 않음)
- 사용한 복제 방법: 미확인 — 개인본 패널 구성(Metric·Donut·Bar·Treemap·http_status ×2)이 공통 원본 패널(Metric·category Bar·brand Table·price Bar·Donut·Line)과 전혀 겹치지 않는다. `Save as`/`Duplicate`로 만들었다면 처음엔 같은 6패널에서 시작했어야 하므로, 실제로는 새 Dashboard로 별도 제작했을 가능성이 높다. 정확한 생성 방법은 재확인이 필요하다.
- 상단 제목이 개인본으로 바뀌었는가: 예(`내꺼`로 별도 저장됨)
- Dashboard 목록에 원본과 개인본이 모두 있는가: 예 — `수업2`, `내꺼` 둘 다 존재한다.
- 캡처 파일: `evidence/day-04/personal-dashboard.png`

## (개인·필수) 문제 2 — 청사진대로 서로 다른 패널 4개 제작

| 질문 | 패널 제목 | field | 계산·그룹 | 차트 | 실제 결과 | 완료 기준 통과 |
|---|---|---|---|---|---|---|
| Q1 | 전체 로그 수 | (전체 문서) | Count of records | Metric | 1,000 | 통과 |
| Q2 | (제목 미확인) | `log_level` | Terms + Count | Donut, Bar(같은 질문 중복 표현) | INFO 71.1%(711) / WARN 18.8%(188) / ERROR 10.1%(101) | 통과(단, 패널 2개가 같은 질문) |
| Q3 | (제목 미확인) | `log_level`, `exception_class` | 중첩 Terms | Treemap | INFO 내 IllegalStateException 30 · SocketTimeoutException 29 · NullPointerException 17 / WARN 내 NullPointerException 9 · SocketTimeoutException 7 · IllegalStateException 3 / ERROR 내 NullPointerException 6 · SocketTimeoutException 4 · IllegalStateException 2 | 통과 |
| Q4 | Top 100 / Top 9 values of http_status(Lens 기본 라벨) | `http_status` | Terms + Count | Metric(Top values breakdown) ×2 | 200: 735 / 500: 109 / 504: 107 / 404: 49 | 통과(단, 패널 2개가 거의 중복이고 제목이 기본값) |

- 공통본에서 변경한 요소 2개 이상: field(`category`→`log_level`/`exception_class`/`http_status`), 차트 유형(Bar/Table/Line→Donut/Treemap/Metric breakdown), 질문 자체가 전부 다름
- 만들지 못한 패널과 이유: 서비스(`service_name`)별 비교 패널 — Control/Filter를 만들지 않기로 결정해 화면에서 나눠 보는 기능은 넣지 않았다.
- 사용한 대체 질문 또는 데이터 보강 계획: 없음(4개 질문 모두 기존 field로 답 가능해 보강 불필요)

## (개인·필수) 문제 3 — 제목과 배치만 보고 질문을 이해하게 만들기

| 수정 전 제목 | 수정 후 제목 | 사용자가 알게 되는 것 |
|---|---|---|
| Count of records(기본) | 전체 로그 수 | 지금까지 쌓인 로그가 몇 건인지 |
| (제목 없음, Donut) | 로그 레벨 비율 | INFO/WARN/ERROR 구성비 |
| (제목 없음, Treemap) | 레벨별 예외 유형 분포 | 어떤 예외가 어떤 레벨에서 많이 나는지 |
| Top 100 / Top 9 values of http_status | HTTP 상태 코드 분포 | 5xx 오류 비중이 큰지 |

수정 후 제목은 설계안이며, 실제 Kibana 화면에 전부 반영했는지는 재확인이 필요하다(`personal-dashboard.png` 캡처 시점 기준으로는 Metric 패널 외에는 제목 표시줄이 뚜렷이 보이지 않았다).

- 가장 중요한 패널: 로그 레벨별 예외 유형 분포(Treemap) — 우선 조치 대상을 판단하는 핵심 근거이기 때문
- 가장 크게 배치한 이유: Treemap이 화면에서 가장 넓은 영역을 차지하도록 배치했다(중첩 정보량이 많아서).
- 잘림·겹침을 수정한 패널: 미확인
- 수정 후 전체 화면 캡처: `evidence/day-04/personal-dashboard.png`

## (개인·필수) 문제 4 — 개인 질문용 Control 또는 Filter

미수행. `service_name` 기준 Control 또는 Filter를 만들지 않기로 결정했다(`evidence/day-04/dashboard-review.md` 2절).

- 선택한 방식: 없음
- field: 해당 없음
- label 또는 조건: 해당 없음
- 이 조건이 필요한 사용자 행동: (설계상) 특정 서비스만 골라 예외 분포를 보고 싶을 때
- 적용 전 핵심값: 해당 없음
- 적용 후 핵심값: 해당 없음
- 함께 변한 다른 패널: 해당 없음
- 해제 방법: 해당 없음
- 해제 후 복구값: 해당 없음
- 캡처 파일: 없음

## (선택 도전) 문제 5 — 확장 차트 하나의 필요성 심사

- 후보 차트: Treemap
- 답하려는 질문: 로그 레벨별로 어떤 예외 클래스가 주로 발생하는가
- 필요한 field: `log_level`, `exception_class`
- 기본 Bar/Table보다 나은 점: 레벨(상위)과 예외(하위)의 중첩 비율을 한 화면에서 동시에 볼 수 있다. Bar/Table로는 2단계 그룹을 한 번에 표현하기 어렵다.
- 오해할 위험: 칸 크기가 작아지면 정확한 수치를 읽기 어렵고, 레벨별 "예외 없음" 문서가 많다는 사실이 잘 드러나지 않는다(예: ERROR 101건 중 위 3개 예외 클래스 합은 12건뿐이고 나머지 89건은 `exception_class`가 없다).
- 추가/보류 결정: 추가함
- 추가했다면 검증 결과: 화면의 레벨별 비율(INFO 71.03%, WARN 17.76%, ERROR 11.21%)이 `log_level` 실측 비율(71.1%/18.8%/10.1%)과 대체로 비슷하지만 정확히 일치하지는 않는다. 특히 WARN(17.76% vs 18.8%), ERROR(11.21% vs 10.1%)에 근소한 차이가 있어 원인은 추가 확인이 필요하다(`evidence/day-04/dashboard-review.md` 3절에 기록).

## 교시 완료 신호

- GREEN: 개인본, 4패널, 의미 있는 제목·배치, 상호작용 1개 완료
- YELLOW: 3패널 또는 상호작용 검증 미완료
- RED: 개인 Dashboard 복제나 저장 불가

**판정: YELLOW** — 개인본과 질문 4개를 답하는 패널(실제로는 6개)까지는 완료했다. 문제4(Control/Filter 상호작용)를 만들지 않기로 결정해 그 부분만 미완료로 남았다.
