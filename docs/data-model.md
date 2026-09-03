# Day 2 데이터 모델

## V1-T09-P · 문서 단위

- 개인 index 이름: `shop-logs`
- 검색 결과 한 줄 / 문서 한 건의 의미: log4j2 JSON Layout으로 찍힌 로그 한 줄
- 업무 ID field / 예시 값: `log_id` / `LOG-000002`
- ES `_id`와 업무 ID 관계: Bulk 때 `_id`를 `log_id`와 동일하게 지정. `GET /shop-logs/_doc/LOG-000002`로 바로 조회 가능

## V1-T10-P · 질문3개

| 번호 | 사용자 질문 | 검색어 | 조건 | 정렬 | 표시 field |
|---|---|---|---|---|---|
| Q1 | "시간 초과"가 언급된 로그를 찾고 싶다 | `message`: "시간 초과" | 없음 | 없음 | `timestamp`, `service_name`, `message` |
| Q2 | 결제 서비스에서 난 ERROR만 보고 싶다 | 없음 | `service_name=payment-api`, `log_level=ERROR` | 없음 | `timestamp`, `log_level`, `duration_ms` |
| Q3 | 결제 서비스에서 시간 초과된 ERROR 중 3초 이상인 것을 느린 순으로 보고 싶다 | `message`: "시간 초과" | `service_name=payment-api`, `log_level=ERROR`, `duration_ms>=3000` | `duration_ms desc`, `timestamp desc` | `log_id`, `message`, `duration_ms` |

대표3건은 ../data/sample-documents.json에 저장한다.

| 문서 | 포함/제외/경계 역할 | 연결 질문 | 예상과 field 근거 |
|---|---|---|---|
| `LOG-000001` | 제외 사례 | Q1, Q2 | log_level INFO라 Q2 제외, message에 "시간 초과" 없어 Q1도 제외 |
| `LOG-000002` | 포함 사례 | Q1, Q2, Q3 | payment-api, ERROR, duration_ms 3021, message에 "시간 초과" 있음 |
| `LOG-000003` | 경계 사례 | Q2 | log_level WARN이라 "ERROR만" 조건 바로 아래 |

## V1-T11-P · field 계약

| field | 예시 값 | 검색/필터/정렬/표시/집계 | type | 질문 번호 | 선택 이유 |
|---|---|---|---|---|---|
| `log_id` | `LOG-000002` | 표시 | `keyword` | 전체 | Bulk `_id`와 1:1 식별자 |
| `timestamp` | `2026-08-30T14:22:07Z` | 정렬·표시·집계 | `date` | Q1, Q3 | 장애 시간대 좁히기, 최신순 정렬 |
| `service_name` | `payment-api` | 필터·표시·집계 | `keyword` | Q2, Q3 | 서비스별 필터 |
| `log_level` | `ERROR` | 필터·표시·집계 | `keyword` | Q2, Q3 | INFO/WARN/ERROR 구분 |
| `logger_name` | `com.shop.payment-api.RequestHandler` | 필터 | `keyword` | - | 클래스 단위 필터 |
| `message` | `게이트웨이 응답이 3000ms 후 시간 초과되었습니다.` | 검색 | `text` | Q1, Q3 | 문장 검색 |
| `exception_class` | `SocketTimeoutException` | 필터·집계 | `keyword` | - | 예외 종류별 집계 |
| `http_status` | `504` | 필터 | `integer` | - | 응답 코드 필터 |
| `duration_ms` | `3021` | 필터·정렬·표시 | `integer` | Q3 | 느린 요청 검색, 정렬 |
| `trace_id` | `TRC-2` | 표시 | `keyword` | - | 요청 흐름 추적 |

- 배열/객체 여부와 제공 생성기 지원 범위: 전부 flat scalar. 배열/nested 미사용. 생성기가 scalar와 단순 배열만 지원하고 로그에는 배열 쓸 field가 없음
- 제외한 개인정보/불필요한 field와 이유: 이용자 ID, 이메일, 결제 수단, 접속 IP 제외. 장애 원인 추적에 불필요. 요청 추적은 합성 `trace_id`로 대체
- 자가 점검으로 수정한 내용: Day 1 초안의 `@timestamp` → `timestamp` (생성기가 field 이름에 `@` 미허용). message는 `analysis-nori` 미설치로 standard 사용
- 완전한 mapping: ../elasticsearch/index-create.json
