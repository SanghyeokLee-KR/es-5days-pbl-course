# Day 4 개인 Dashboard 설계

## 1. 사용자와 목적

- 내 주제: 쇼핑몰 백엔드 log4j 로그 트러블슈팅 검색 시스템
- 이 Dashboard를 볼 사람: 백엔드 운영, 장애 대응 담당자
- Dashboard를 보고 결정하거나 행동할 것: 어떤 예외부터 잡을지
- 사용할 index / Data View: `shop-logs`

## 2. 데이터 준비 경로

- [x] A: 개인 데이터로 제작
- [ ] B: 공통 products로 제작하며 개인 데이터 보강 규칙 작성
- [ ] C: 공통 Dashboard를 완성하고 개인 청사진에 집중

선택 이유: `shop-logs`에 log_level, exception_class, http_status, duration_ms가 다 있음

## 3. 질문-데이터-차트 청사진

| 번호 | 분석 질문 | 필요한 field | 현재 존재? | mapping type | 계산·그룹 방식 | 차트 | filter/control | 확인 기준 |
|---|---|---|---|---|---|---|---|---|
| Q1 전체 규모 | 로그가 총 몇 건인가 | (전체 문서) | 있음 | - | Count of records | Metric | 없음 | `GET /shop-logs/_count`와 동일 |
| Q2 그룹 비교 | 로그 레벨 비율이 어떤가 | `log_level` | 있음 | keyword | Terms + Count | Donut, Bar | 없음 | Day2 실측 71.1/18.8/10.1과 동일 |
| Q3 분포/정확한 값 | 레벨별로 어떤 예외가 많이 나는가 | `log_level`, `exception_class` | 있음 | keyword, keyword | 레벨 안에 예외로 한 번 더 | Treemap | 없음 | 레벨별 비율 합이 전체 비율과 근사 |
| Q4 상태/시간 | HTTP 상태 코드가 어떻게 나뉘는가 | `http_status` | 있음 | integer | Terms + Count | Metric(Top values) 2개 | 없음 | 코드별 합 = 전체 건수 |

Q2는 Donut, Bar 두 개인데 같은 내용

## 4. 데이터 부족 분석

- 현재 데이터로 답할 수 없는 질문: 서비스(`service_name`)별 예외/상태코드 분포. field는 있으나 filter/control 미생성
- 부족한 field: 없음
- 필요한 mapping type: 해당 없음
- 필요한 값의 범위·범주·비율: 해당 없음
- 날짜가 필요하다면 기간과 단위: 해당 없음(질문 4개 다 시간축 미사용)
- 한 문서가 의미할 사건 또는 대상: log4j2 JSON Layout 로그 한 줄
- 생성 또는 수집 방법: `my-data-settings.ps1` 생성기, seed 고정, 1,000건 Bulk
- 데이터 수가 충분하다고 판단할 기준: 목표 70/20/10에 실측 71.1/18.8/10.1

## 5. 제작 순서

1. `shop-logs` Data View에서 Metric(전체 로그 수)
2. log_level Donut/Bar
3. log_level × exception_class Treemap
4. http_status Top values

## 6. 완료 예상 화면

- Dashboard 제목: 개인 PBL Dashboard - 이상혁
- 필수 패널 수: 6
- 사용할 control/filter: 없음
- 저장할 캡처 파일명: `personal-dashboard.png`
