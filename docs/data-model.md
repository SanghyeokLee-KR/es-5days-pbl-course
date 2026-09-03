# Day 2 데이터 모델

## V1-T09-P · 문서 단위

- 개인 index 이름: `shop-logs`
- 검색 결과 한 줄 / 문서 한 건의 의미: log4j2 JSON Layout으로 찍힌 로그 한 줄
- 업무 ID field / 예시 값: `log_id` / `LOG-000002`
- ES `_id`와 업무 ID 관계: Bulk 넣을 때 `_id`를 `log_id`랑 똑같이 줬다. 그래서 `GET /shop-logs/_doc/LOG-000002`로 바로 꺼낼 수 있다

## V1-T10-P · 질문3개

| 번호 | 사용자 질문 | 검색어 | 조건 | 정렬 | 표시 field |
|---|---|---|---|---|---|
| Q1 | "시간 초과"가 언급된 로그를 찾고 싶다 | `message`: "시간 초과" | 없음 | 없음 | `timestamp`, `service_name`, `message` |
| Q2 | 결제 서비스에서 난 ERROR만 보고 싶다 | 없음 | `service_name=payment-api`, `log_level=ERROR` | 없음 | `timestamp`, `log_level`, `duration_ms` |
| Q3 | 결제 서비스에서 시간 초과된 ERROR 중 3초 이상인 것을 느린 순으로 보고 싶다 | `message`: "시간 초과" | `service_name=payment-api`, `log_level=ERROR`, `duration_ms>=3000` | `duration_ms desc`, `timestamp desc` | `log_id`, `message`, `duration_ms` |

대표3건은 ../data/sample-documents.json에 저장한다.

| 문서 | 포함/제외/경계 역할 | 연결 질문 | 예상과 field 근거 |
|---|---|---|---|
| `LOG-000001` | 제외 사례 | Q1, Q2 | log_level이 INFO라 Q2에서 빠지고, message에 "시간 초과"가 없어 Q1에서도 빠진다 |
| `LOG-000002` | 포함 사례 | Q1, Q2, Q3 | payment-api, ERROR, duration_ms 3021, message에 "시간 초과" 있음. 세 질문 다 걸린다 |
| `LOG-000003` | 경계 사례 | Q2 | log_level이 WARN이라 "ERROR만" 조건 바로 아래에 걸린다 |

## V1-T11-P · field 계약

| field | 예시 값 | 검색/필터/정렬/표시/집계 | type | 질문 번호 | 선택 이유 |
|---|---|---|---|---|---|
| `log_id` | `LOG-000002` | 표시 | `keyword` | 전체 | Bulk `_id`랑 1:1로 맞춘 식별자 |
| `timestamp` | `2026-08-30T14:22:07Z` | 정렬·표시·집계 | `date` | Q1, Q3 | 장애 시간대로 좁히고 최신순 정렬 |
| `service_name` | `payment-api` | 필터·표시·집계 | `keyword` | Q2, Q3 | 서비스별로 걸러야 해서 |
| `log_level` | `ERROR` | 필터·표시·집계 | `keyword` | Q2, Q3 | INFO/WARN/ERROR 구분 |
| `logger_name` | `com.shop.payment-api.RequestHandler` | 필터 | `keyword` | - | 클래스 단위로 좁힐 때 |
| `message` | `게이트웨이 응답이 3000ms 후 시간 초과되었습니다.` | 검색 | `text` | Q1, Q3 | "시간 초과" 같은 문장을 찾아야 해서 |
| `exception_class` | `SocketTimeoutException` | 필터·집계 | `keyword` | - | 예외 종류별로 세려고 |
| `http_status` | `504` | 필터 | `integer` | - | 응답 코드로 걸러야 해서 |
| `duration_ms` | `3021` | 필터·정렬·표시 | `integer` | Q3 | 느린 요청 찾고 정렬하려고 |
| `trace_id` | `TRC-2` | 표시 | `keyword` | - | 요청 흐름 따라갈 때 |

- 배열/객체 여부와 제공 생성기 지원 범위: 전부 flat scalar다. 배열이나 nested는 안 썼다. 생성기가 scalar랑 단순 배열만 되는데 로그에는 배열 쓸 field가 딱히 없었다
- 제외한 개인정보/불필요한 field와 이유: 이용자 ID, 이메일, 결제 수단, 접속 IP는 안 넣었다. 장애 원인을 로그로 찾는 과제라 필요가 없다. 요청 추적은 합성 `trace_id`로 대신했다
- 자가 점검으로 수정한 내용: Day 1 초안에 `@timestamp`로 적었는데 생성기가 field 이름에 `@`를 안 받아서 `timestamp`로 바꿨다. Kibana Data View는 아무 date field나 시간 field로 지정할 수 있어서 Day 4에는 영향이 없었다. message는 nori를 쓰고 싶었지만 강의용 ES 이미지에 `analysis-nori`가 안 깔려 있어서(`GET /_cat/plugins?v` 결과 비어 있음) standard로 갔다
- 완전한 mapping: ../elasticsearch/index-create.json
