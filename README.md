# 쇼핑몰 백엔드 log4j 로그 트러블슈팅 PBL

## 1. 프로젝트 소개

- 문제와 사용자: 장애 신고 받은 백엔드 운영 담당자가 서비스, 로그레벨, 시각으로 원인 로그를 찾는다
- ES로 검색할 문서 1건: log4j2 JSON Layout 로그 한 줄
- 이 주제를 선택한 이유: 메시지 검색에 서비스/레벨 조건과 처리시간 범위를 같이 걸어보려고

## 2. 실행 순서

1. Docker 환경 시작: `day-01/docker`에서 `.env` 준비 후 `start.ps1`, `status.ps1`
2. index와 mapping 생성: `requests.http` V1-T12-P, mapping은 `elasticsearch/index-create.json`
3. 데이터 생성·Bulk 적재: `data/pbl-data-template` 생성기, seed `20260901`, 1,000건
4. 검색 요청 실행: `requests.http` V1-T17-P~V1-T21-P
5. Kibana Dashboard 확인: `evidence/day-04/common-dashboard.png`, `personal-dashboard.png`

## 3. 데이터와 mapping

- 문서 수: 1,000건
- 데이터 생성 규칙과 seed: seed `20260901`, log_level 목표 70/20/10에 실측 71.1/18.8/10.1
- 개인정보 미사용 확인: 전부 합성 로그
- 핵심 필드와 타입 선택 이유: log_level, service_name, exception_class는 필터·집계라 keyword. message는 문장 검색이라 text. duration_ms, http_status는 범위 검색이라 숫자

## 4. 검색·품질 테스트

| 검색 질문 | 기대 결과 | 실제 결과 | 판정 |
|---|---|---|---|
| "시간 초과" 언급된 로그 | 전체 10%쯤 | 100건 (10%) | 통과 |
| 결제 서비스 ERROR만 | service=payment-api, level=ERROR | 20건 | 통과 |
| 결제 서비스 느린 ERROR(3초 이상) 최근순 | duration_ms>=3000 | 3건 | 통과 |

- 상세: [docs/quality-test.md](docs/quality-test.md), [evidence/day-03-search.md](evidence/day-03-search.md)
- 생성 설정파일 BOM 누락으로 검색이 1건만 잡히던 것 수정

## 5. Dashboard

- Dashboard 사용자: 백엔드 운영, 장애 대응 담당자
- 차트 1이 답하는 질문: 전체 로그가 몇 건인가 (Metric)
- 차트 2가 답하는 질문: 로그 레벨별 비율은 어떤가 (Donut)
- control/filter 목적: 미생성 ([evidence/day-04/dashboard-review.md](evidence/day-04/dashboard-review.md))

## 6. AI Search 확장 판단

- 적용 여부와 근거: Day 5 전이라 미정
