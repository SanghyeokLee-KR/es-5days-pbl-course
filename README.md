# 쇼핑몰 백엔드 log4j 로그 트러블슈팅 PBL

## 1. 프로젝트 소개

- 문제와 사용자: 장애 신고 받은 백엔드 운영 담당자가 서비스·로그레벨·발생시각으로 원인 로그를 찾는다
- ES로 검색할 문서 1건: log4j2 JSON Layout 로그 이벤트 1건
- 이 주제를 선택한 이유: 메시지 전문 검색에 서비스·레벨 조건이랑 처리시간 범위까지 같이 걸어보고 싶어서

## 2. 실행 순서

1. Docker 환경 시작: `day-01/docker`에서 `.env` 준비하고 `start.ps1`, `status.ps1`
2. index와 mapping 생성: `requests.http`의 V1-T12-P, mapping은 `elasticsearch/index-create.json`
3. 데이터 생성·Bulk 적재: `data/pbl-data-template`에서 생성기 실행 (seed `20260901`, 1,000건)
4. 검색 요청 실행: `requests.http`의 V1-T17-P~V1-T21-P
5. Kibana Dashboard 확인: `evidence/day-04/common-dashboard.png`, `personal-dashboard.png`

## 3. 데이터와 mapping

- 문서 수: 1,000건
- 데이터 생성 규칙과 seed: seed `20260901`, log_level 목표비율 70/20/10 (실제 71.1/18.8/10.1)
- 개인정보 미사용 확인: 합성 로그 데이터, 개인정보 없음
- 핵심 필드와 타입 선택 이유: `log_level`/`service_name`/`exception_class`는 keyword(필터·집계용), `message`는 text(전문검색용), `duration_ms`/`http_status`는 숫자(범위검색·정렬용)

## 4. 검색·품질 테스트

| 검색 질문 | 기대 결과 | 실제 결과 | 판정 |
|---|---|---|---|
| "시간 초과" 언급된 로그 | 전체 10%대 | 100건 (10%) | 통과 |
| 결제 서비스 ERROR만 | service=payment-api, level=ERROR | 20건 | 통과 |
| 결제 서비스 느린 ERROR(3초 이상) 최근순 | duration_ms>=3000 | 3건 | 통과 |

- 상세: [docs/quality-test.md](docs/quality-test.md), [evidence/day-03-search.md](evidence/day-03-search.md)
- 데이터 생성 설정파일 인코딩 문제(BOM 누락)로 검색이 1건만 잡히던 버그를 발견해서 고침

## 5. Dashboard

- Dashboard 사용자: 백엔드 운영·장애 대응 담당자
- 차트 1이 답하는 질문: 전체 로그가 몇 건인가 (Metric)
- 차트 2가 답하는 질문: 로그 레벨별 비율은 어떤가 (Donut)
- control/filter 목적: 아직 미적용 — 시간 제약으로 만들지 않기로 함 ([evidence/day-04/dashboard-review.md](evidence/day-04/dashboard-review.md) 참고)

## 6. AI Search 확장 판단

- 적용 여부와 근거: Day 5 진행 전이라 아직 미정
