# Day 4 개인 Dashboard 설계

## 1. 사용자와 목적

- 내 주제: 쇼핑몰 백엔드 log4j 로그 트러블슈팅 검색 시스템
- 이 Dashboard를 볼 사람: 백엔드 운영·장애 대응 담당자
- Dashboard를 보고 결정하거나 행동할 것: 로그 레벨·예외 유형·HTTP 상태 분포를 보고 어떤 예외를 우선 조치할지 판단
- 사용할 index / Data View: `shop-logs`

## 2. 데이터 준비 경로

- [x] A: 개인 데이터로 제작
- [ ] B: 공통 products로 제작하며 개인 데이터 보강 규칙 작성
- [ ] C: 공통 Dashboard를 완성하고 개인 청사진에 집중

선택 이유: Day 2에 생성·적재한 `shop-logs` 1,000건에 `log_level`, `exception_class`, `http_status`, `duration_ms` 등 필요한 field가 이미 있어 별도 데이터 보강 없이 개인 데이터로 제작했다.

## 3. 질문-데이터-차트 청사진

| 번호 | 분석 질문 | 필요한 field | 현재 존재? | mapping type | 계산·그룹 방식 | 차트 | filter/control | 확인 기준 |
|---|---|---|---|---|---|---|---|---|
| Q1 전체 규모 | 전체 로그가 몇 건인가 | (전체 문서) | 있음 | - | Count of records | Metric | 없음 | `GET /shop-logs/_count`와 일치 |
| Q2 그룹 비교 | 로그 레벨(INFO/WARN/ERROR) 비율은 어떤가 | `log_level` | 있음 | keyword | Terms + Count | Donut, Bar(같은 질문을 두 표현으로 중복 표시) | 없음 | Day2 실측 비율(71.1/18.8/10.1%)과 일치 |
| Q3 분포/정확한 값 | 로그 레벨별로 어떤 예외 클래스가 주로 발생하는가 | `log_level`, `exception_class` | 있음 | keyword, keyword | 중첩 Terms(레벨→예외) | Treemap | 없음 | 레벨별 비율 합이 전체 레벨 비율과 근접 |
| Q4 상태/시간 | HTTP 상태 코드는 어떻게 분포하는가 | `http_status` | 있음 | integer | Terms + Count | Metric(Top values breakdown) ×2 | 없음 | 코드별 합이 전체 문서 수와 일치 |

## 4. 데이터 부족 분석

- 현재 데이터로 답할 수 없는 질문: 서비스(`service_name`)별로 예외·상태코드를 나눠 보는 질문 — field는 있지만 filter/control을 만들지 않아 화면에서 바로 나눠 볼 수 없다.
- 부족한 field: 없음(질문 4개에 필요한 field는 이미 존재)
- 필요한 mapping type: 해당 없음
- 필요한 값의 범위·범주·비율: 해당 없음
- 날짜가 필요하다면 기간과 단위: 해당 없음(이번 4개 질문은 시간축을 쓰지 않음)
- 한 문서가 의미할 사건 또는 대상: log4j2 JSON Layout으로 남은 로그 이벤트 1건
- 생성 또는 수집 방법: `data/pbl-data-template/my-data-settings.ps1` 생성기로 seed 고정, 1,000건 Bulk 적재(`evidence/day-02-data.md` 참고)
- 데이터 수가 충분하다고 판단할 기준: `log_level` 목표 비율(70/20/10)과 실측 비율(71.1/18.8/10.1)이 근접해 대표성이 있다고 판단

## 5. 제작 순서

1. `shop-logs` Data View에서 Metric(전체 로그 수) 패널 생성
2. `log_level` Donut/Bar로 레벨 비율 확인
3. `log_level` × `exception_class` Treemap으로 세부 예외 분포 확인
4. `http_status` Top values 패널로 상태 코드 분포 확인
5. Dashboard로 조립 후 저장

## 6. 완료 예상 화면

- Dashboard 제목: 개인 PBL Dashboard - 이상혁
- 필수 패널 수: 6 (요구 4개 이상 충족)
- 사용할 control/filter: 없음 — 시간 제약으로 미적용 결정(`dashboard-review.md` 2절 참고)
- 저장할 캡처 파일명: `personal-dashboard.png`
