# 데이터 모델 (Day 2 확정)

## 1. 문서 단위 (V1-T09-P)

- 개인 index 이름: `shop-logs`
- 검색 결과 한 줄 / 문서 한 건의 의미: log4j2 JSON Layout으로 남은 로그 이벤트 1건
- 업무 ID field / 예시 값: `log_id` / `LOG-000002`
- ES `_id`와 업무 ID 관계: Bulk 적재 시 `_id`를 `log_id` 값과 동일하게 지정한다(1:1 대응). 그래서 `GET /shop-logs/_doc/LOG-000002`처럼 업무 ID로 바로 문서를 조회할 수 있다.

## 2. 질문 3개 (V1-T10-P)

| 번호 | 사용자 질문 | 검색어 | 조건 | 정렬 | 표시 field |
|---|---|---|---|---|---|
| Q1 | "시간 초과"가 언급된 로그를 찾고 싶다 | `message`: "시간 초과" | 없음 | 없음 | `timestamp`, `service_name`, `message` |
| Q2 | 결제 서비스에서 난 ERROR만 보고 싶다 | 없음 | `service_name=payment-api`, `log_level=ERROR` | 없음 | `timestamp`, `log_level`, `duration_ms` |
| Q3 | 결제 서비스에서 시간 초과된 ERROR 중 3초 이상인 것을 느린 순으로 보고 싶다 | `message`: "시간 초과" | `service_name=payment-api`, `log_level=ERROR`, `duration_ms>=3000` | `duration_ms desc`, `timestamp desc` | `log_id`, `message`, `duration_ms` |

대표 3건은 `data/sample-documents.json`에 저장했다.

| 문서 | 포함/제외/경계 역할 | 연결 질문 | 예상과 field 근거 |
|---|---|---|---|
| `LOG-000001` | 제외 사례 | Q1, Q2 | `log_level=INFO`라 Q2에서 제외, `message`에 "시간 초과"가 없어 Q1에서도 제외 |
| `LOG-000002` | 포함 사례 | Q1, Q2, Q3 | `service_name=payment-api`, `log_level=ERROR`, `duration_ms=3021`(≥3000), `message`에 "시간 초과" 포함 — 세 질문 모두 만족 |
| `LOG-000003` | 경계 사례 | Q2 | `log_level=WARN`이라 "ERROR만"이라는 Q2 조건의 바로 아래 경계값(ERROR 아님)을 보여준다 |

## 3. 확정 mapping (V1-T11-P)

Day 1 초안의 `@timestamp`는 생성기가 field 이름에 `@`를 허용하지 않아 `timestamp`로 바꿨다. Kibana에서 Data View의 시간 field로 아무 `date` field나 지정할 수 있어 Day 4 작업에는 영향이 없다. 이것이 Day 1 초안에서 자가 점검으로 수정한 내용이다.

| field | 예시 값 | 검색/필터/정렬/표시/집계 | type | 질문 번호 | 선택 이유 |
|---|---|---|---|---|---|
| `log_id` | `LOG-000002` | 표시 | `keyword` | 전체 | Bulk `_id`와 1:1 대응하는 식별자 |
| `timestamp` | `2026-08-30T14:22:07Z` | 정렬·표시·집계 | `date` | Q1, Q3 | 장애 시간대로 좁히고 최신순 정렬 |
| `service_name` | `payment-api` | 필터·표시·집계 | `keyword` | Q2, Q3 | 서비스별 필터·비교 |
| `log_level` | `ERROR` | 필터·표시·집계 | `keyword` | Q2, Q3 | INFO/WARN/ERROR 구분 |
| `logger_name` | `com.shop.payment-api.RequestHandler` | 필터 | `keyword` | - | 클래스 단위 필터 |
| `message` | `게이트웨이 응답이 3000ms 후 시간 초과되었습니다.` | 검색 | `text` | Q1, Q3 | "시간 초과" 같은 한국어 문장 검색 |
| `exception_class` | `SocketTimeoutException` | 필터·집계 | `keyword` | - | 예외 종류별 집계 |
| `http_status` | `504` | 필터 | `integer` | - | 응답 코드 필터 |
| `duration_ms` | `3021` | 필터·정렬·표시 | `integer` | Q3 | 느린 요청 검색·정렬 |
| `trace_id` | `TRC-2` | 표시 | `keyword` | - | 요청 흐름 추적 |

- 배열/객체 여부와 제공 생성기 지원 범위: 전부 flat scalar field다. 배열이나 nested 객체는 쓰지 않았다 — 데이터 생성기가 scalar와 단순 배열(`tags` 같은 것)만 지원하고 우리 로그 도메인에는 배열이 필요한 field가 없었다.
- `message`는 `nori` 분석기를 쓰고 싶었지만 이 강의용 ES 이미지에는 `analysis-nori` 플러그인이 설치돼 있지 않다(`GET /_cat/plugins?v` 결과 없음). 그래서 공통 상품 예제와 같은 방식으로 `standard` analyzer에 `stopwords: _none_`를 적용했다.
- 완전한 mapping: `elasticsearch/index-create.json`

## 4. 제외한 개인정보

- 제외한 field와 이유: 이용자 ID·이메일·결제 수단·접속 IP는 사용하지 않는다. 이 PBL은 장애 원인을 로그로 찾는 과제이며 개인정보가 필요하지 않다. 요청 추적은 합성 `trace_id`로 대신한다.
