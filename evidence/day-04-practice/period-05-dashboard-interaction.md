# 5교시 연습 — Dashboard 조립·Control·Filter·KQL

- 필수 권장 시간: 42분
- 선택 도전: 3분
- 제출 상태 확인: 5분
- 시작 기준: 공통 필수 6패널 완성
- 화면 순서: [패널 제목·배치](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#11-dashboard-배치제목패널-메뉴), [Control](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#12-category-options-list-control), [Filter 복구](../../day-04/KIBANA_9_5_STEP_BY_STEP.md#13-controlfilterkql-사용과-복구)

## (공통·필수) 문제 1 — 6패널을 읽는 순서로 배치

### 배치 기록

- Dashboard 제목: 수업2
- 첫 행 패널: 전체 상품 수 Metric, 카테고리별 상품 수 Bar
- 둘째 행 패널: 브랜드별 상품 수와 평균 가격 Table, 재고 상태 비율 Donut, 가격 구간별 상품 수 Bar
- 셋째 행 패널: 월별 상품 등록 분포 Line(전체 폭)
- 가장 크게 배치한 패널과 이유: brand Table — 10개 행과 두 열(브랜드명, 평균 가격)을 한 번에 보여줘야 해서 다른 패널보다 세로로 길게 배치했다.
- 크기를 늘려 해결한 가독성 문제: 미확인 — 별도로 기록하지 않았다.
- 제목이 비어 있던 패널과 수정 결과: 화면 캡처상 Metric·category Bar·Donut 패널 위에 제목 표시줄이 뚜렷이 보이지 않는다. 실제로 제목이 비어 있는지, 표시 옵션이 꺼져 있는 것인지는 캡처만으로 확정할 수 없어 재확인이 필요하다.
- 캡처 파일: `evidence/day-04/common-dashboard.png`

## (공통·필수) 문제 2 — category Options list 추가

Dashboard 편집 모드에서 category Control을 추가하세요.

### 전후 기록

미수행. 공통 Dashboard에 category Control을 만들지 않기로 결정했다(`evidence/day-04/dashboard-review.md` 2절). 이유: 6패널 제작과 조립까지는 완료했고, 남은 시간 안에서는 Control/Filter 상호작용보다 Day4 전체 진도를 맞추는 쪽을 우선했다.

- 선택한 category: 미수행
- 적용 전 Metric: 미수행
- 적용 후 Metric: 미수행
- 함께 바뀐 패널 2개: 미수행
- `Any` 복구 후 Metric: 미수행
- 정상 여부: 해당 없음
- 캡처 파일: 없음

## (진단·필수) 문제 3 — Control·Filter·KQL을 구분하고 초기화

다음 세 방식을 한 번씩 사용하세요.

| 방식 | 입력한 조건 | 적용 전 값 | 적용 후 값 | 해제 방법 | 해제 후 값 |
|---|---|---:|---:|---|---:|
| Control | 미수행(Control 자체를 만들지 않음) | - | - | - | - |
| Filter | 미수행 | - | - | - | - |
| KQL | 미수행 | - | - | - | - |

- 세 방식의 사용자가 느끼는 차이: 실제 조작으로 확인하지 못했다. 문서상 이해로는 Control은 재사용 가능한 드롭다운, Filter는 pill로 남는 고정 조건, KQL은 검색창에 직접 입력하는 임시 조건이라는 차이가 있다.
- 모든 조건 제거 후 전체값: 해당 없음(조건을 적용한 적이 없어 처음부터 9,818/10,000 상태 유지)
- `Filter for value` 문구가 없을 때 확인한 filter pill과 변한 패널: 해당 없음
- 캡처 파일: 없음

이 문제는 필수로 표시돼 있지만 시간 제약과 Control/Filter 미생성 결정으로 세 방식 모두 실제 조작을 하지 않았다. 예상값으로 채우지 않고 미수행 그대로 기록한다.

## (공통·필수) 문제 4 — 목요일 종료용 저장·재열기

Dashboard를 `D4 공통 상품 Dashboard - 이름`으로 저장한 뒤 Dashboard 목록으로 나갔다가 다시 여세요.

### 저장·복구 기록

- 실제 저장 이름: 수업2 (가이드 권장 이름 `D4 공통 상품 Dashboard - 이상혁`으로는 아직 다시 저장하지 않음)
- 저장 시각: 미확인
- 다시 열기 성공 여부: 미확인 — 별도로 재현·기록하지 않았다.
- 패널 수: 6
- Control 초기값: 해당 없음(Control 없음)
- KQL/filter 상태: 없음
- Metric 값: 9,818
- 다시 열었을 때 달라진 항목: 미확인
- 전체 화면 캡처: `evidence/day-04/common-dashboard.png`

## (선택 도전) 문제 5 — 30초 사용성 테스트

미수행(선택 문제) — 함께 테스트할 동료 학생이 없어 시도하지 않았다.

## 교시 완료 신호

- GREEN: 6패널+Control, 세 조건 전후, 저장·재열기, 최종 20,000 완료
- YELLOW: 저장은 됐지만 조건이나 값이 초기화되지 않음
- RED: Dashboard를 저장하거나 다시 열 수 없음

**판정: YELLOW** — 6패널 배치와 저장은 완료했지만, Control 추가(문제2)와 Control/Filter/KQL 구분(문제3)은 의도적으로 만들지 않기로 결정해 미수행이다. 저장·재열기 재확인(문제4)도 별도로 검증하지 않았다.
