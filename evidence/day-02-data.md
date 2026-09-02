# Day 2 데이터 준비 결과

> 확인 일시: 2026-09-01

## 1. Index와 문서

- Index 이름: `shop-logs`
- 문서 한 건의 의미: log4j2 JSON Layout으로 남은 로그 이벤트 1건
- 실제 색인 건수: 1000 (`GET /shop-logs/_count` → `{"count":1000}`)
- Mapping의 `dynamic` 설정: `strict`
- Shard 배치(`GET /_cat/shards/shop-logs?v`): `0 p STARTED` es01, `0 r STARTED` es02 — primary·replica 모두 정상 배치(UNASSIGNED 없음)

## 2. 최종 Field

| Field | Type | 검색에서 사용할 목적 |
|---|---|---|
| `log_id` | `keyword` | 문서 ID |
| `timestamp` | `date` | 범위·정렬·시간대별 집계 |
| `service_name` | `keyword` | 서비스별 필터·집계 |
| `log_level` | `keyword` | INFO/WARN/ERROR 필터·집계 |
| `logger_name` | `keyword` | 클래스 단위 필터 |
| `message` | `text` | "시간 초과" 같은 문장 전문 검색 |
| `exception_class` | `keyword` | 예외 종류별 집계 |
| `http_status` | `integer` | 응답 코드 필터 |
| `duration_ms` | `integer` | 느린 요청 범위 검색·정렬 |
| `trace_id` | `keyword` | 요청 흐름 추적 |

## 3. 대량 데이터 생성·색인 결과

- 생성 건수: 1,000건 (표본 30건 별도, seed `20260901`)
- 로컬 검증 결과: `validate-data.ps1` → `LOCAL CHECK PASS: 1000 documents, unique IDs, target index and NDJSON verified.`
- Bulk 색인 결과: `load-data.ps1` → `PASS: Bulk item errors=false. Actual count=1000, generated=1000.`
- ES 실제 `_count`: `{"count":1000}`
- 분류·숫자·boolean 분포 확인 결과:
  - `log_level`: INFO 711(71.1%) / WARN 188(18.8%) / ERROR 101(10.1%) — 목표 70/20/10과 근접
  - `service_name`: 4개 서비스 239~261건으로 고른 분포
  - `duration_ms` stats: count 1000, min 50.0, max 4994.0, avg 2557.98 — 설정 범위(50~5000)와 대체로 일치

## 4. CRUD 검증

| 단계 | 요청 | 실제 결과 |
|---|---|---|
| 시작 count | `GET /shop-logs/_count` | 1000 |
| 생성 | `PUT /shop-logs/_doc/LOG-TEST01` | `result: created`, `_version: 1` |
| 조회 | `GET /shop-logs/_doc/LOG-TEST01` | `found: true`, `_source` 일치 |
| 수정 | `POST /shop-logs/_update/LOG-TEST01` (`log_level`→WARN, `duration_ms`→980) | `result: updated`, `_version: 2` |
| 수정 후 재조회 | `GET /shop-logs/_doc/LOG-TEST01` | `log_level: WARN`, `duration_ms: 980`로 변경 확인 |
| 삭제 | `DELETE /shop-logs/_doc/LOG-TEST01` | `result: deleted`, `_version: 3` |
| 삭제 후 재조회 | `GET /shop-logs/_doc/LOG-TEST01` | `found: false` |
| 종료 count | `GET /shop-logs/_count` | 1000 (생성·삭제로 원상 복귀) |

선택 확인 — 동일 값 update의 `noop`과 두 번째 DELETE의 `not_found`(`LOG-TEST04`):

| 단계 | 요청 | 실제 결과 |
|---|---|---|
| 생성 | `PUT /shop-logs/_doc/LOG-TEST04` | `result: created` |
| 동일 값으로 update | `POST /shop-logs/_update/LOG-TEST04` (`log_level`을 이미 있는 값 `INFO`로) | `result: noop`, `_shards.total: 0` — 실제 변경이 없어 아무 shard에도 쓰기가 일어나지 않음 |
| 첫 번째 DELETE | `DELETE /shop-logs/_doc/LOG-TEST04` | `result: deleted` |
| 두 번째 DELETE | `DELETE /shop-logs/_doc/LOG-TEST04` | `result: not_found` — 이미 없는 문서를 다시 지워도 오류가 아니라 `not_found`로 응답함 |

## 5. 분석(`_analyze`) 비교 — 개인 검색어 3개

`nori` 플러그인이 없어 `standard`(`log_message_analyzer`)와 `whitespace`를 비교했다.

| 검색어 | 예상 token | standard 실제 token | whitespace 실제 token | 차이 이유 |
|---|---|---|---|---|
| "시간 초과" | `시간`, `초과` | `시간`, `초과` | `시간`, `초과` | 검색어 자체는 공백 구분이라 두 analyzer가 동일하게 분리함 |
| "재시도" | `재시도` | `재시도` | `재시도` | 검색어 단독으로는 그대로 한 token |
| "정상적으로 완료" | `정상적으로`, `완료` | `정상적으로`, `완료` | `정상적으로`, `완료` | 공백 기준 분리로 동일 |

실제 데이터에서는 검색어와 문서 토큰이 다르게 갈린다. `message` 원문 "요청 처리 중 재시도가 발생했습니다."를 분석하면 `재시도가`가 하나의 token으로 묶인다(조사 "가"가 분리되지 않음). 그래서 검색어 "재시도"(token: `재시도`)로 `match` 검색하면 문서의 `재시도가` token과 일치하지 않아 **0건**이 나온다 — 3교시 실습(`evidence/day-03-practice/period-02-term-match.md`)에서 발견했던 현상의 원인을 여기서 `_analyze`로 확정했다.

같은 이유로 "시간 초과되었습니다."의 `초과되었습니다`도 하나의 token이라, 검색어 "초과"만으로는 일치하지 않는다("시간"만 일치). `nori` 같은 형태소 분석기가 없어 조사·어미가 분리되지 않는 것이 이 index의 공통된 한계다.

## 6. 공통 ingest pipeline simulate (V1-T16-C, products 대상)

`product-cleanup` pipeline(재고 기본값 설정, `brand_name`→`brand` 이름 변경, `temp`·`raw_price` 제거)을 생성하고 4가지 입력으로 `_simulate`를 실행했다. `_simulate`는 저장하지 않는다.

| 입력 사례 | 예상 변화 | 실제 결과 |
|---|---|---|
| Samsung (`in_stock` 없음) | `in_stock`이 `true`로 채워지고 `brand_name`이 `brand`로 바뀌며 `temp`·`raw_price` 제거 | `in_stock: true`, `brand: "Samsung"`, `temp`·`raw_price` 없음 — 예상과 일치 |
| Apple (`category` 있음) | 위와 동일, `category`는 그대로 보존 | `brand: "Apple"`, `category: "전자기기"` 유지, `temp`·`raw_price` 제거 — 일치 |
| `in_stock: false` 명시 | `set` processor가 `override:false`라 기존 값을 덮지 않아야 함 | `in_stock: false` 그대로 유지됨 — 예상과 일치, `override:false`의 실제 동작 확인 |
| `temp` 필드 누락 | `remove` processor가 없는 field를 지우려다 오류를 낼 것으로 예상 | `illegal_argument_exception: field [temp] not present as part of path [temp]` — 예상대로 오류, 문서 저장 없음 |

우리 `shop-logs` 데이터는 생성 시점에 이미 올바른 type으로 만들어져 pipeline이 필요 없지만(`docs/pipeline-decision.md` 참고), 이 실습으로 pipeline이 어떤 상황에서 필요한지(형식 정리, 이름 변경, 기본값 채우기, 결측 필드 처리)는 확인했다.

## 7. Day 3 연결

- 검색 질문 기준: `docs/data-model.md`의 사용자 질문 3개("시간 초과" 로그 검색 / 결제 서비스 느린 ERROR / 서비스별 에러 요약)

## 8. 결과 파일 위치

- Mapping: `elasticsearch/index-create.json`
- 실행 요청: `requests.http`
- 대표 문서: `data/sample-documents.json`
- 데이터 생성 설정: `data/pbl-data-template/my-data-settings.ps1`
- 생성 표본: `data/pbl-data-template/generated/shop-logs-sample-30.ndjson`
- 생성 요약: `data/pbl-data-template/generated/generation-summary.json`

## 9. Pipeline 적용 판단

- 적용 / 미적용 / 보류: 미적용
- 판단 이유: 데이터가 log4j2 JSON Layout으로 이미 필드 단위로 구조화되어 있어 grok 등 파싱 단계가 필요 없다. 상세 근거는 `docs/pipeline-decision.md`. 공통 `product-cleanup` 실습(6절)으로 pipeline 동작 자체는 별도로 확인했다.

## 10. 미완료·오류

- 없음. index 생성, mapping 확인, 분석 방식 비교, CRUD(수정 포함), 1,000건 생성·적재·분포 검증, 공통 pipeline simulate까지 모두 완료했다.
- 다음에 할 작업: Day 4 aggregation·Dashboard.

대표 3건은 `-FixedDocumentsFile ..\sample-documents.json`으로 `LOG-000001~003`에 그대로 삽입했다. `GET /shop-logs/_doc/LOG-000002`로 타임아웃 ERROR 문서가 실제 색인됐음을 확인했다.

> 비밀번호, `.env` 실제 값, 토큰은 기록하지 않는다.
